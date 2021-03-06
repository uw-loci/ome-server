# OME/Web/ImportFiles.pm
# OME local file browser and importer for the OME Web interface.
# this provides the pair of queues and their gui s for ImportImages and 
# ImportModules

#-------------------------------------------------------------------------------
#
# Copyright (C) 2003 Open Microscopy Environment
#       Massachusetts Institute of Technology,
#       National Institutes of Health,
#       University of Dundee
#
#
#
#    This library is free software; you can redistribute it and/or
#    modify it under the terms of the GNU Lesser General Public
#    License as published by the Free Software Foundation; either
#    version 2.1 of the License, or (at your option) any later version.
#
#    This library is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#    Lesser General Public License for more details.
#
#    You should have received a copy of the GNU Lesser General Public
#    License along with this library; if not, write to the Free Software
#    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
#-------------------------------------------------------------------------------




#-------------------------------------------------------------------------------
#
# Written by:    Chris Allan <callan@blackcat.ca>
#
#-------------------------------------------------------------------------------


package OME::Web::ImportFiles;

#*********
#********* INCLUDES
#*********

use strict;
use warnings; 
use vars qw($VERSION);
use Carp;
use Data::Dumper;
use File::Spec;
use File::Glob ':glob'; # for bsd_glob

# OME Modules
use OME;
use OME::Web::FileTable;
use OME::Tasks::DatasetManager;
use OME::Tasks::ImageTasks;

#*********
#********* GLOBALS AND DEFINES
#*********

$VERSION = $OME::VERSION;
use base qw(OME::Web);

use constant UNIX_STYLE => 1;
use constant FTP_STYLE  => 2;

my $STYLE = FTP_STYLE;

#*********
#********* PRIVATE METHODS
#*********

# Build array for hidden CGI import field
sub __processQueue {
	my ($self, $queue, $add, $remove) = @_;

	my %uniq;

	# Build unique hash and add elements
	foreach (@$queue, @$add) { $uniq{$_} = 1; }
	# Remove elements
	foreach (@$remove) { delete($uniq{$_}); }

	return keys(%uniq);
}

# Resolves the import queue array, by recursion
sub __resolveQueue {
	my ($self, $queue) = @_;

	for (my $i = 0; $i <= scalar(@$queue); ++$i) {
		if ($queue->[$i] and -d $queue->[$i]) {
			# Splice off the directory
			my $dir = splice(@$queue, $i, 1);

			# Push its contents
			push(@$queue, bsd_glob("$dir/*"));

			# Changes
			return 1;
		}
	}

	# No changes
	return 0;
}

# De-taint sub for FTP style
sub __detaintPaths {
	my ($self, $paths, $home_dir) = @_;
		
	# Settle the trailing "/" if it exists
	$home_dir = File::Spec->canonpath($home_dir);

	my (@good_paths, @bad_paths);
	my $home_path_len = scalar(File::Spec->splitdir($home_dir));

	foreach (@$paths) {
		unless (File::Spec->file_name_is_absolute($_)) {
			# This should *NEVER* happen from our code, only if someone
			# is mucking around with the CGI variables.
			carp "*WARNING*: Removing *nasty* non-absolute path '$_' in __detaintPaths().";
			push (@bad_paths, $_);
			next;
		}

		# Settle the trailing "/" if it exists
		$_ = File::Spec->canonpath($_);

		my @parts = File::Spec->splitdir($_);
		
		# First checkpoint (evil characters/sequences in the path)
		if ($_ =~ /\.\.\/|\||\\|\;|\:/) {
			push (@bad_paths, $_);
			next;
		# Second checkpoint (path obviously not below the home dir)
		} elsif (scalar(@parts) < $home_path_len) {
			push (@bad_paths, $_);
			next;
		# Third checkpoint (path is not a child of homedir)
		} elsif (not ($_ =~ /^$home_dir.*/)) {
			push (@bad_paths, $_);	
			next;
		}

		push (@good_paths, $_);
	}

	return (\@good_paths, \@bad_paths);
}



sub __getDirListHeader {
	my ($self, $path_dir) = @_;
	my $q = $self->CGI();
	my $home_dir = $self->Session()->User()->DataDirectory();

	my @dirs = File::Spec->splitdir($path_dir);

	my ($running_path, $path_text, $previous_path);

	foreach (@dirs) {
		$running_path = File::Spec->catdir($running_path, $_);
		unless (defined $previous_path and $previous_path eq $running_path) {
			$path_text .= $q->a( {
					-href => '#',
					-onClick => "document.forms['datatable'].Path.value='$running_path'; document.forms['datatable'].submit(); return false",
				}, $_ || '/');
			$path_text .= '/' if $_;  # Root directory is empty
		}
		$previous_path = $running_path;
	}

	# Home icon
	my $icon_td = $q->td($q->a({-href => $self->pageURL(ref($self)) . "&Path=$home_dir"},
		$q->img( {
				border => '0',
				src => '/ome-images/home.png',
				width => '24',
				height => '24'
			})
	));

	# Header text
	my $text_td .= $q->td($q->span({-class => 'ome_title', -align => 'center'},
		"Directory Listing ($path_text)"));

	my $header_table = $q->table({-border => '0', cellspacing => '0', cellpadding => '0'},
		$q->Tr($icon_td, $text_td));

	return $q->p($header_table);
}

sub __getQueueBody {
	my $self = shift;
	my $q = $self->CGI();
	my $user = $self->Session()->User();
	my $home_dir = $user->DataDirectory();

	# Path directory
	my $path_dir = $q->param('Path') || $home_dir;
	   $path_dir = File::Spec->canonpath($path_dir);  # Cleanup path

	# Files or dirs selected from the dir listing
	my @add_selected = $q->param('add_selected');
	
	# Files selected from the import queue
	my @q_selected = $q->param('q_selected');
	
	# Files selected from the import queue
	my @importq = $q->param('import_queue');

	# Action button clicked on
	my $action = $q->param('action') || '';
	
	# CGI cleanup
	$q->delete('action');
	$q->delete('add_selected');
	$q->delete('q_selected');
	$q->delete('import_queue');

	if ($action eq 'Add to Queue') { $action = 'add'; }
	if ($action eq 'Remove from Queue') { $action = 'remove'; }

	my $body;
	
	# Rebuild importq
	if ($action eq 'add') {
	
		# convert into files and directories
		my @add_files;
		my @add_dirs;
		foreach (@add_selected) {
			if (-f $_) {
				push (@add_files, $_);
			} elsif (-d $_) {
				push (@add_dirs, $_);			
			} else {
				$body .= $q->p({-class => 'ome_info'}, "ERROR: OMG What is $_ ?.\n");
			}
		}
		
		@importq = $self->OME::Web::ImportFiles::__processQueue(\@importq, \@add_selected, undef);
		$body .= $q->p({-class => 'ome_info'}, "Added ".scalar( @add_files )." files to the import queue.\n") if( @add_files );
		$body .= $q->p({-class => 'ome_info'}, "Added ".scalar( @add_dirs )." directories to the import queue.\n") if( @add_dirs );
		
	} elsif ($action eq 'remove') {
		@importq = $self->OME::Web::ImportFiles::__processQueue(\@importq, undef, \@q_selected);

		$body .= $q->p({-class => 'ome_info'}, "Removed ".scalar( @q_selected )." files from the import queue.\n") if( @q_selected );
	}

	# If we're running using the FTP style de-taint our paths
	if ($STYLE == FTP_STYLE) {
		my ($good_paths, $bad_paths);

		# De-taint the root path dir
		($good_paths, $bad_paths) = $self->OME::Web::ImportFiles::__detaintPaths([$path_dir], $home_dir);

		# Report badness
		if (@$bad_paths) {
			foreach (@$bad_paths) {
				$body .= $q->p({class => 'ome_error'},
					"You have been returned to your home directory. The path you attempted to enter '$_' was not a child of your home directory '$home_dir' or contained illegal characters."
				);
			}
			$path_dir = $home_dir;
		} else {
			# De-tainted $path_dir
			$path_dir = shift(@$good_paths);
		}
	
		# Also de-taint the importq
		($good_paths, $bad_paths) = $self->OME::Web::ImportFiles::__detaintPaths(\@importq, $home_dir);

		# Report badness
		if (@$bad_paths) {
			foreach (@$bad_paths) {
				$body .= $q->p({class => 'ome_error'},
					"A path '$_' which is not a child of your home directory '$home_dir' or which contained illegal characters, was removed from the 'Import Queue'. Please try again or contact your systems administrator."
				);
			}
		}

		@importq = @$good_paths;
	}

	# Table generator
	my $t_generator = new OME::Web::FileTable;

	$body .= $q->startform({name => 'datatable'});

	# Import queue *hidden*
	$body .= $q->hidden({name => 'import_queue', default => \@importq});

	# Path *hidden*
	$body .= $q->hidden({name => 'Path', default => $path_dir});	
	
	# Action *hidden*
	$body .= $q->hidden({-name => 'action', -default => ''});

	$body .= $self->__getDatasetForm();

	# Directory listing table
	my $dir_list_table = $t_generator->getTable( {
			select_column => '1',
			select_name => 'add_selected',
			parent_pagelink => $self->pageURL(ref($self)),
			parent_form => '1',
			traverse => '1',
			options_row => [
				'Add to Queue',
				['Select All', 'javascript:selectAllCheckboxes(\'add_selected\');'],
				['Reset', 'javascript:deselectAllCheckboxes(\'add_selected\');'],
			],
		}, $path_dir);
	my $dir_list_header = $self->OME::Web::ImportFiles::__getDirListHeader($path_dir);

	# Import queue table
	my $importq_table = $t_generator->getTable ( {
			select_column => '1',
			select_name => 'q_selected',
			parent_pagelink => $self->pageURL(ref($self)),
			parent_form => '1',
			options_row => [
				'Remove from Queue',
				['Select All', 'javascript:selectAllCheckboxes(\'q_selected\');'],
				['Reset', 'javascript:deselectAllCheckboxes(\'q_selected\');'],
			],
		}, @importq);
	my $importq_header = $q->p({-class => 'ome_title', -align => 'center'}, 'Import Queue');

	# Packing table
	$body .= $q->table({width => '100%', border => '0'}, $q->Tr( [
			$q->td({align => 'center'}, $dir_list_header) .
			$q->td({align => 'center'}, $importq_header),
			$q->td({valign => 'top', width => '50%'}, $dir_list_table) .
			$q->td({valign => 'top', width => '50%'}, $importq_table),
		])
	);
	
	$body .= $q->endform();

	return $body;
}
1;
