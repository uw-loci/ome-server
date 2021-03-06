# OME/Web/TableBrowse/HeaderBuilder.pm
# Default header generation class for a non-overriden getPageHeader()

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
# Written by:    Chris Allan <callan@blackcat.ca>,
# Customized by: Harry Hochheiser <hsh@nih.gov>, for Mouse Gene Index
#
#-------------------------------------------------------------------------------


package OME::Web::TableBrowse::HeaderBuilder;

#*********
#********* INCLUDES
#*********

use strict;
use vars qw($VERSION);
use CGI;
use Carp;

# OME Modules
use OME;
use OME::Task;
use OME::Web;
use OME::Tasks::NotificationManager;

#*********
#********* GLOBALS AND DEFINES
#*********

$VERSION = $OME::VERSION_STRING;

my $HOME_LOCATION = 'serve.pl?Page=OME::Web::TableBrowse&Base=1';

my $NIH_LOCATION = 'http://www.nih.gov';
my $NIA_LOCATION = 'http://www.grc.nia.nih.gov';
my $MGI_LOCATION = 'http://lgsun.grc.nia.nih.gov/geneindex5'; 
my $OME_LOCATION = 'http://www.openmicroscopy.org';
#*********
#********* PRIVATE METHODS
#*********

# Session Macro (Pseudo-private)
sub Session { OME::Session->instance() };

#*********
#********* PUBLIC METHODS
#*********

sub new {
	my $proto = shift;
	my $class = ref($proto) || $proto;

	my $self = {};

	return bless($self,$class);
}

sub getPageHeader {
	my $self = shift;
	my $q = new CGI;

	# Session goodies

	# Logo image link
	my $logo;
	
	$logo =
	    $q->img( {
		alt => 'OME Logo',
		src => '/ome-images/logo-4.png',
		border => '0'
		} );
	
	my $nia_link = $q->a({href=>$NIA_LOCATION},	
			   $q->img({
					alt=>'NIA Logo',
					src=>'/ome-images/nia1.jpg',
					border=>'0'
				   }
 				)
			);
	
	# Our glorious header table
	my $header_table = $q->table( {
			width => '100%',
			border => '0',
			cellpadding => '0',
			cellspacing => '0',
		},
		$q->Tr(	$q->td($nia_link),
			$q->td( {-align => 'center', -valign => 'top' },
				$q->span({class => 'ome_menu_title' }, 
				$q->a({href=>$OME_LOCATION},'Open Microscopy Environment')).
				' v'.$VERSION
			),
			$q->td($logo),
		)
	);

	return $header_table;
    }


1;
