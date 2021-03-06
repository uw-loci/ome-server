# OME/Web/DBObjDetail/__OME_Dataset.pm

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
# Written by:    Josiah Johnston <siah@nih.gov>
#
#-------------------------------------------------------------------------------


package OME::Web::DBObjDetail::__OME_Dataset;

=pod

=head1 NAME

OME::Web::DBObjDetail::__OME_Dataset

=head1 DESCRIPTION

_takeAction() sets Session->dataset to the dataset displayed and
implements adding images to the dataset and
implements editing name or description and.

=cut

#*********
#********* INCLUDES
#*********

use strict;
use OME;
our $VERSION = $OME::VERSION;
use OME::Tasks::DatasetManager;
use OME::Tasks::CategoryManager;
use OME::Web::DBObjDetail::__Category;
use OME::Tasks::PixelsManager;

use Log::Agent;
use base qw(OME::Web::DBObjDetail);

sub getPageBody {
	my $self = shift;
	my $html = ( $self->_takeAction( ) || '' );
	my $q = $self->CGI();
	my $dataset = $self->_loadObject();
	my $factory = $self->Session()->Factory();

	my $tmpl = 
	    OME::Web::TemplateManager->getRenderingTemplate('OME::Dataset',
							  'detail','one');

	my %tmpl_data = $self->Renderer()->_populate_object_in_template( $dataset, $tmpl );
	
	my %cgi_params = $q->Vars();
	
	# Find category groups used in this dataset. They will be used for the
	# dropdown list that allows clustering thumbnails by categories.
	my @cg_list = $factory->findObjects ('@CategoryGroup',
		'CategoryList.ClassificationList.image.dataset_links.dataset' => $dataset->id(),
		__distinct => ['Name', 'id'],
		__order    => ['Name', 'id'],
	);
	my @unused_cg_list = $factory->findObjects ('@CategoryGroup',
		( scalar( @cg_list ) ? 
			('id' => [ 'not in', [ map( $_->id, @cg_list ) ] ] ) : 
			()
		),
		__distinct => ['Name', 'id'],
		__order    => ['Name', 'id'],
	);
	@cg_list = ( @cg_list, @unused_cg_list );

	# load the selected category group. 
	# 	selected_cg        comes from the search popup (or create popup)
	# 	group_images_by_cg comes from the dropdown list
	my $cg_id = $q->param( 'selected_cg' ) || $q->param( 'group_images_by_cg' );
	my $cg;
	if( $cg_id ) {
		$cg = $factory->loadObject( '@CategoryGroup', $cg_id )
			or die "Couldn't load CategoryGroup id='$cg_id'";
	}

	# make the CategoryGroup dropdown list
	$tmpl_data{ categories_used } = (
		@cg_list ?
		$q->popup_menu(
			-name     => 'group_images_by_cg',
			'-values' => ['', map( $_->id, @cg_list) ],
			-default  => ( $cg_id || '' ),
			-override => 1,
			-labels   => { 
				'' => "(no selection)",
				( map { $_->id => $_->Name } @cg_list )
			},
			-onChange => "javascript: document.forms[0].submit();"
		) : 
		'(No CategoryGroups are used by this Dataset)'
	);

	# Use selected CategoryGroup to group images.
	if( $cg ) {
		my @category_list = $cg->CategoryList( __order => 'Name' );
		# Entries will be removed from this hash as images are found to belong
		# to this cg. What's left will be the list of unclassified images.
		my %images_lacking_classifications = map(
			{ $_->id => $_ } 
			$dataset->images()
		);
		# The dropdown list of categories to go with 'Classify Image As ...'
		$tmpl_data{ available_categories }        = $q->popup_menu(
			-name     => 'category_to_classify_with',
			'-values' => [ map( $_->id, @category_list) ],
			-labels   => { map { $_->id => $_->Name } @category_list }
		) if @category_list;
		$tmpl_data{ selected_category_group_ref } = $self->Renderer()->render( $cg, 'ref' );
		# The images sorted by Category
		foreach my $category ( @category_list ) {
			my @classifications = OME::Tasks::CategoryManager->
				getClassificationsInDataset( $category, $dataset );
			my @images = map( $_->image, @classifications );
			delete $images_lacking_classifications{ $_->id }
				foreach @images;
			push( @{ $tmpl_data{ _CategoryList } }, {
				CategoryRef => $self->Renderer()->render( $category, 'ref' ),
				images      => $self->Renderer()->renderArray( 
					\@images, 'ref_mass_w_paging', { type => 'OME::Image', pager_control_name => 'images_in_cat_'.$category->id } 
				),
			} );
		}
		# The unclassified images
		my @unclassified_images = sort( 
			{ $a->name cmp $b->name }
			values %images_lacking_classifications
		);
		unshift( @{ $tmpl_data{ _CategoryList } }, {
			CategoryRef => 'Unclassified',
			images      => $self->Renderer()->renderArray( \@unclassified_images, 'ref_mass_w_paging', { type => 'OME::Image', pager_control_name => 'unclassified_images' } ),
		} );
		
		# a link to save these classifications as a table.
		$tmpl_data{ downloadClassificationsAsTableURL } = $self->getTableURL(
			'@Classification',
			'Valid'                          => 1,
			'Category.CategoryGroup'         => $cg,
			'image.dataset_links.dataset_id' => $dataset,
			'__order'                        => ['image.name', 'image', '!module_execution.timestamp'],
			'__distinct'                     => ['image.name', 'image'],
			'__fields'                       => ['image', 'image.name', 'Category', 'Category.Name', 'id', 'Confidence', 'Valid', 'module_execution', 'module_execution.module.name', 'module_execution.timestamp', 'module_execution.experimenter.LastName', 'module_execution.experimenter.Email' ],
		);
		# a link to save all classifications as a table.
		$tmpl_data{ downloadAllClassificationsAsTableURL } = $self->getTableURL(
			'@Classification',
			'Valid'                          => 1,
			'Category.CategoryGroup'         => $cg,
			'image.dataset_links.dataset_id' => $dataset,
			'__order'                        => ['image.name'], 
			'__fields'                       => ['image', 'image.name', 'Category', 'Category.Name', 'id', 'Confidence', 'Valid', 'module_execution', 'module_execution.module.name', 'module_execution.timestamp', 'module_execution.experimenter.LastName', 'module_execution.experimenter.Email' ],
		);
	}
	
	
	$tmpl->param( %tmpl_data );
	$self->{ form_name } = 'primary';
	$html .= $q->startform( { -name => $self->{ form_name } } ).
	         $q->hidden({-name => 'Type', -default => $q->param( 'Type' ) }).
	         $q->hidden({-name => 'ID', -default => $q->param( 'ID' ) }).
	         $q->hidden({-name => 'action', -default => ''}).
	         $tmpl->output().
	         $q->endform();

	return ('HTML', $html);
}


sub _takeAction {
	my $self = shift;
	my $dataset = $self->_loadObject();
	my $q = $self->CGI();
	my $message;
	my $session = $self->Session();
	my $factory = $session->Factory();

	# make this dataset the "most recent"
	$session->dataset( $dataset );
	$session->storeObject();
	$session->commitTransaction();
	
	# Edits
	if( $q->param( 'action' ) && $q->param( 'action' ) eq 'Save' ) {
		# Edit name or description
		if( $q->param( 'description' ) || $q->param( 'name' ) ) {
			$dataset->description( $q->param( 'description' ) );
			$dataset->name( $q->param( 'name' ) );
			$dataset->storeObject();
			$session->commitTransaction();
		}
		# Edit annotation
		if( $q->param( 'annotation' ) ) {
			OME::Tasks::DatasetManager->writeAnnotation( 
				$dataset, { Content => $q->param( 'annotation' ) }
			);
			$session->commitTransaction();
		}
	}
	
	# Delete Annotation
	if( $q->param('action') && 
	    $q->param( 'action' ) eq 'DeleteAnnotation' ) {
		OME::Tasks::DatasetManager->deleteCurrentAnnotation( $dataset );
		$session->commitTransaction();
	}

	# Add images
	my $image_ids_to_add = $q->param( 'images_to_add' );
	if( $image_ids_to_add ) {
		$message .= $self->DatasetUtil()->addImages($image_ids_to_add);
	}
	
	# remove images
	my $image_ids_to_remove = $q->param( 'images_to_remove' );
	if( $image_ids_to_remove ) {
		$message .= $self->DatasetUtil()->removeImages($image_ids_to_remove);
	}
	
	# Declassify image
	my $image_id_to_declassify = $q->param( 'declassifyImage' );
	if( $image_id_to_declassify && $image_id_to_declassify ne '' ) {
		my $image = $factory->loadObject( 'OME::Image', $image_id_to_declassify )
			or die "Couldn't load image (id=$image_id_to_declassify)";
		my $cg_id = $q->param( 'group_images_by_cg' );
		die "No category group selected."
			unless ( $cg_id && $cg_id ne '' );
		my $cg = $factory->loadObject( '@CategoryGroup', $cg_id )
			or die "Couldn't load CategoryGroup ID=$cg_id";
		my $classification = OME::Tasks::CategoryManager->
			getImageClassification( $image, $cg );
		if (not defined $classification ) {
			$message .= "<font color='red'>Image ".$self->Renderer()->render( $image, 'ref' )." is already unclassified.</font><br>";
		} elsif ( ref( $classification ) eq 'ARRAY' ) {
			$message .= "<font color='red'>Image ".$self->Renderer()->render( $image, 'ref' )." has multiple (".
			scalar( @$classification ).") classifications in this CategoryGroup. This page isn't capable of dealing with that.</font><br>";
		} else {
			OME::Tasks::CategoryManager->
				declassifyImage( $image, $classification->Category() );
			$message .= "Declassified image ".$self->Renderer()->render( $image, 'ref' ).".<br>";
		}
	}
	
	# allow image classification
	my $image_id_to_classify = $q->param( 'classifyImage' );
	if( $image_id_to_classify && $image_id_to_classify ne '') {
		my $category_id = $q->param( 'category_to_classify_with' );
		$message .= $self->CategoryUtil()->
			classify( $image_id_to_classify, $category_id );
	}
	
	# change image displays
	my $blackLevelInGeoSigmas = $q->param( 'blackGeoSigma' );
	my $whiteLevelInGeoSigmas = $q->param( 'whiteGeoSigma' );
	my $channelSpecifier      = $q->param( 'channelSpecifier' );
	# Simple translation of channel specifier for now: assume single channel
	my $channelIndex = 0;
	if( (defined $blackLevelInGeoSigmas) && ( $blackLevelInGeoSigmas ne '' ) && 
	    (defined $whiteLevelInGeoSigmas) && ( $whiteLevelInGeoSigmas ne '' ) && 
	    (defined $channelIndex ) 
	  ) {
		my @images = $dataset->images();
		foreach my $image( @images ) {
			my $pixels_attr = $image->default_pixels();
			unless( $pixels_attr ) {
				$message .= "Could not set display of image ".$image->name." (id:".$image->id.") because it has no pixels.<br>";
				next;
			}
		    my $pixels_data = OME::Tasks::PixelsManager->loadPixels( $pixels_attr );
			my $statsHash   = $pixels_data->getStackStatistics();
			my $displayOptions = OME::Tasks::PixelsManager->getDisplayOptions( $pixels_attr );
			my $theT = ($displayOptions->TStart() + $displayOptions->TStop() ) / 2;
			my ( $absoluteBlackLevel, $absoluteWhiteLevel );
			$absoluteBlackLevel = int( 0.5 + $statsHash->{ $channelIndex }{ $theT }->{Geomean} + 
				$blackLevelInGeoSigmas * $statsHash->{ $channelIndex }{ $theT }->{Geosigma}  );
			$absoluteBlackLevel = $statsHash->{ $channelIndex }{ $theT }->{Minimum}
				if $absoluteBlackLevel < $statsHash->{ $channelIndex }{ $theT }->{Minimum};
			$absoluteWhiteLevel = int( 0.5 + $statsHash->{ $channelIndex }{ $theT }->{Geomean} + 
				$whiteLevelInGeoSigmas * $statsHash->{ $channelIndex }{ $theT }->{Geosigma} );
			$absoluteWhiteLevel = $statsHash->{ $channelIndex }{ $theT }->{Maximum}
				if $absoluteWhiteLevel > $statsHash->{ $channelIndex }{ $theT }->{Maximum};
			
			# Still maintaining simplistic assumption of single channel images.
			my $displayChannel = $displayOptions->GreyChannel();
			$displayChannel->BlackLevel( $absoluteBlackLevel );
			$displayChannel->WhiteLevel( $absoluteWhiteLevel );
			$displayChannel->storeObject();
			
			$pixels_data->setThumb( $displayOptions );
		}
		$session->commitTransaction();
		$message .= 'Reset black and white level of '.scalar( @images ).' images.<br>';
	}
	
	return $message;
}



=head1 Author

Josiah Johnston <siah@nih.gov>

=cut

1;
