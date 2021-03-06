#!/usr/bin/perl -w
#
# OME::ImportEngine::BMPreader.pm
#
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
# Written by:    Nico Stuurman <nicos@itsa.ucsf.edu>
# Based on code by:
#                Brian S. Hughes
#				 Arpun Nagaraja
#
#-------------------------------------------------------------------------------


#

=head1 NAME

OME::ImportEngine::BMPreader.pm  -  single & group BMP image importer

=head1 SYNOPSIS

    use OME::ImportEngine::BMPreader
    my $bmpFormat = new BMPreader($session, $module_execution)
    my $groups = $bmpFormat->getGroups(\@filenames)
    my $image = $bmpFormat->importGroup(\@filenames)

=head1 DESCRIPTION

This importer class handles regular BMP format images. The getGroups()
method discovers which files in a set of files have the BMP format,
and the importGroup() method imports BMP format files into OME 5D
image files and metadata.

The  getGroups() method will assemble groups of BMP files that
together comprise a 5D image, as well as identifying single stand-alone
BMP files. The importGroup() method will import a multi-file
group, stitching together the individual BMP images into a single
5D OME image. It will also import a single file 'group' into an OME
5D image.

=cut



package OME::ImportEngine::BMPreader;
use Class::Struct;
use strict;
use File::Basename;
use Log::Agent;
use OME::ImportEngine::BMPUtils;
use base qw(OME::ImportEngine::AbstractFormat);

use vars qw($VERSION);
use OME;
$VERSION = $OME::VERSION;

use Carp;
use Data::Dumper;

=head2 Patterns Defining Groups

All the files in a BMP file group will have the same filename pattern. 
Each filename will have a common base, and a variable part that identifies 
the instance of a group variable that the file represents. For instance,
a BMP group that has images of the same plate well taken at 2 different
illumination wavelengths could have files named "plate4_well54_w1.bmp"
and "plate4_well54_w2.bmp".

To group related files together, a call to getRegexGroups() in the superclass
is used, followed by sorting and verification that files are indeed BMPs.

=head1 METHODS


The following public methods are available:



=head2 B<getGroups> S< > S< > S< >

    my $group_output_list = $importer->getGroups(\@filepaths)

This method examines the list of filenames that is passed in by
reference. If a file has the .bmp extensions and contains the 
BMP identifyer bytes in its begining,
it is declared to be BMP format. Any files on the list that are 
declared BMP files are removed from the input list and added to the 
output list. 

If a set of these BMP files match any of the criteria that define a 
group, that set is added as an array to the output list. Any BMP file 
that does not belong to such a group is placed into its own array (a 
group of 1) and placed on the output list. 

For each group, this method also determines what the OME repository 
image filename will be for that group. It then pushes this output name 
onto the arrary of input filenames; the importGroup() method will later 
extract it and create it in the repository to hold the new import.

=cut


sub getGroups {
    my $self = shift;
    my $fref = shift;
    my @outlist;
    my ($file_id,$file);
    my $filename;
	 my %BMPs;
logdbg "debug", ref ($self)."->getGroups: CHECKING FILES";
	
	# ignore any non-bmp files.
	while ( ($file_id,$file) = each %$fref ) {
		if (defined(verifyBMP($file))) {
         $BMPs{$file_id} = $file;
         logdbg "debug", ref($self)."->getGroups: Adding file: $file";
      }
	}

    # Group files with recognized patterns together
    # Sort them by channels, z's, then timepoints
    my ($groups, $infoHash) = $self->getRegexGroups(\%BMPs);

	my ($name,$group);
    while ( ($name,$group) = each %$groups ) {
    	next unless defined($name);
    	my $nZfiles = $infoHash->{ $name }->{ nZfiles };
		my $nCfiles = $infoHash->{ $name }->{ nCfiles };
		my $nTfiles = $infoHash->{ $name }->{ nTfiles };
		my @groupList;
	
		for (my $z = 0; $z < $nZfiles; $z++) {
    		for (my $c = 0; $c < $nCfiles; $c++) {
    			for (my $t = 0; $t < $nTfiles; $t++) {
    				$file = $group->[$z][$c][$t]->{File};
    				die "Uh, file is not defined at (z,c,t)=($z,$c,$t)!\n"
    					unless ( defined($file) );
    				
					# The other keys of this hash give access to the actual
					# sub-patterns matched by the RE:
    				# $zString = $group->[$z][$c][$t]->{Z};
    				# $cString = $group->[$z][$c][$t]->{C};
    				# $tString = $group->[$z][$c][$t]->{T};
					# Note that undef strings are converted to ''.
    				
    				push (@groupList, $file);
    				
    				# delete the file from the hash, so it's not processed by other importers
            $filename = $file->getFilename();
    				$file_id = $file->getFileID();
					logdbg "debug",  "deleting $filename in group $name";
					delete $fref->{ $file_id };
					delete $BMPs{ $file_id };
    			}
    		}
    	}
    	push (@outlist, {
    		Files => \@groupList,
    		BaseName => $name,
    		GroupInfo => $group,
    		nZfiles  => $nZfiles,
    		nCfiles  => $nCfiles,
    		nTfiles  => $nTfiles,
    	})
    		if ( scalar(@groupList) > 0 );
    }
  
    # Now look at the rest of the files in the list to see if there area any other bmps.
    foreach $file ( values %BMPs ) {
    	
      $file_id = $file->getFileID();
    	$filename = $file->getFilename();
    	my $basename = $self->nameOnly($filename);
    	my $group;
    	$group->[0][0][0]={
    		File => $file,
    		Z    => undef,
    		C    => undef,
    		T    => undef,
    	};
    	push (@outlist, {
    		Files => [$file],
    		BaseName => $basename,
    		GroupInfo => $group,
    		nZfiles  => 1,
    		nCfiles  => 1,
    		nTfiles  => 1,
    	});
		logdbg "debug",  ref($self) ."->getGroups: deleting $filename in singleton group $basename";
		delete $fref->{ $file_id };
		delete $BMPs{ $file_id };
    }
	
    return \@outlist;
}




=head2 importGroup

    my $image = $importer->importGroup(\@filenames)

This method imports a group of related BMP files into a single
OME 5D image. The caller passes the ordered set of input files 
comprising the group  (plus the name of the output file to create)
by reference. This method opens each file in turn, extracting its
metadata and pixels, and adding them to the accumulating OME pixels
and metadata.

If all goes well, this method returns a pointer to a freshly created
OME::Image. In that case, the caller should commit any outstanding
image creation database transactions. If the module detects an error,
it will return I<undef>, signalling the caller to rollback any associated
database transactions.

=cut

sub importGroup {
    my ($self, $group, $callback) = @_;

    my $session = $self->Session();
    my $factory = $session->Factory();
    
    my $groupList = $group->{Files};
    
    my $file = $groupList->[0];
    my $filename = $file->getFilename();
    $file->open('r');
logdbg "debug",  ref($self) ."->importGroup: Reading $filename";
    my $bmpinfo = readBMPinfo($file);
    $file->close();

	my $sizeX = $bmpinfo->{'sizeX'};
	my $sizeY = $bmpinfo->{'sizeY'};
	my $sizeZ = $group->{nZfiles};
	my $sizeC = $group->{nCfiles};
	my $sizeT = $group->{nTfiles};
	my $bpp = $bmpinfo->{'bpp'};
	my $offset = $bmpinfo->{'offset'};
	
	my $basename = $group->{BaseName};
	my $image = $self->newImage($basename);
	$self->{image} = $image;

	my ($pixels, $pix) = $self->createRepositoryFile($image, 
						 $sizeX,$sizeY,$sizeZ,$sizeC,$sizeT,$bpp);
	my @channelInfo;
	

	# The files are processed in this way because
	# of the sorting done in the getGroups method.
	for (my $z = 0; $z < $sizeZ; $z++) {
		for (my $c = 0; $c < $sizeC; $c++) {
			for (my $t = 0; $t < $sizeT; $t++) {
				eval {
					$file = shift( @$groupList );
					logdbg "debug",  "shifted ".$file->getFilename();
					# the last 1 means we want to do a horizontal flip
					$pix->convertPlane($file, $offset, $z, $c, $t, 0, 1);						
				};
				
				die "convertPlane failed: $@\n" if $@;
				$self->doSliceCallback($callback);
				$self->storeOneFileInfo($file, $image,
							  0, $sizeX-1,
							  0, $sizeY-1,
							  $z, $z,
							  $c, $c,
							  $t, $t,
							  "BMP");
			}
		}
	}

	for (my $c = 0; $c < $sizeC; $c++) {
		push @channelInfo, {chnlNumber => $c,
							ExWave     => undef,
							EmWave     => undef,
							Fluor      => undef,
							NDfilter   => undef};
	}
	OME::Tasks::PixelsManager->finishPixels( $pix, $pixels );

	$self->storeChannelInfo ($image, @channelInfo);
	$self->storeDisplayOptions ($image);
	return $image;
}

sub getSHA1 {
    my $self = shift;
    my $grp = shift;

    my $file = $grp->{Files}->[0];
    my $sha1 = $file->getSHA1();

    return $sha1;
}

sub cleanup {
}

=head1 Authors

Nico Stuurman
Brian S. Hughes
Arpun Nagaraja

=head1 SEE ALSO

L<OME::ImportEngine::ImportEngine>

=cut

1;







