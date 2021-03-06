# OME/Web/DBObjRender/__OME_Image.pm
#-------------------------------------------------------------------------------
#
# Copyright (C) 2003 Open Microscopy Environment
#		Massachusetts Institute of Technology,
#		National Institutes of Health,
#		University of Dundee
#
#
#
#	 This library is free software; you can redistribute it and/or
#	 modify it under the terms of the GNU Lesser General Public
#	 License as published by the Free Software Foundation; either
#	 version 2.1 of the License, or (at your option) any later version.
#
#	 This library is distributed in the hope that it will be useful,
#	 but WITHOUT ANY WARRANTY; without even the implied warranty of
#	 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#	 Lesser General Public License for more details.
#
#	 You should have received a copy of the GNU Lesser General Public
#	 License along with this library; if not, write to the Free Software
#	 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
#-------------------------------------------------------------------------------




#-------------------------------------------------------------------------------
#
# Written by:  
#	Josiah Johnston <siah@nih.gov>
#
#-------------------------------------------------------------------------------


package OME::Web::DBObjRender::__OME_Image;

=pod

=head1 NAME

OME::Web::DBObjRender::__OME_Image - Specialized rendering for OME::Image

=head1 DESCRIPTION

Provides custom behavior for rendering an OME::Image

=head1 METHODS

=cut

use strict;
use OME;
our $VERSION = $OME::VERSION;

use OME::Tasks::ImageManager;
use OME::Session;
use OME::Tasks::ModuleExecutionManager;
use OME::Web::XMLFileExport;
use Carp 'cluck';
use base qw(OME::Web::DBObjRender);

=head2 _renderData

makes virtual fields 
	thumb_url: an href to the thumbnail of the Image's default pixels
	export_url: an href to download an ome xml file of this image
	current_annotation: the text contents of the current Image annotation
		according to OME::Tasks::ImageManager->getCurrentAnnotation()
	current_annotation_author: A ref to the author of the current annotation 
		iff it was not written by the user
	annotation_count: The total number of annotations about this image
	original_file: HTML snippet containing one or more links to the image's
		original files (if any exist)

=cut

sub _renderData {
	my ($self, $obj, $field_requests, $options) = @_;
	my $session = OME::Session->instance();
	my $factory = $session->Factory();
	my $q       = $self->CGI();
	my %record;

	# thumbnail url
	if( exists $field_requests->{ 'thumb_url' } ) {
		foreach my $request ( @{ $field_requests->{ 'thumb_url' } } ) {
			my $request_string = $request->{ 'request_string' };
			$record{ $request_string } = OME::Tasks::ImageManager->getThumbURL( $obj );
		}
	}
	# export url
	if( exists $field_requests->{ 'export_url' } ) {
		foreach my $request ( @{ $field_requests->{ 'export_url' } } ) {
			my $request_string = $request->{ 'request_string' };
			$record{ $request_string } = OME::Web::XMLFileExport->getURLtoExport( $obj->name().'.ome', $obj->id );
		}
	}
	# current_annotation:
	if( exists $field_requests->{ 'current_annotation' } ) {
		foreach my $request ( @{ $field_requests->{ 'current_annotation' } } ) {
			my $request_string = $request->{ 'request_string' };
			my $currentAnnotation = OME::Tasks::ImageManager->
				getCurrentAnnotation( $obj );
			$record{ $request_string } = $currentAnnotation->Content
				if $currentAnnotation;
		}
	}
	# last_data_1
	if( exists $field_requests->{ 'last_data_1' } ) {
		foreach my $request ( @{ $field_requests->{ 'last_data_1' } } ) {
			my $request_string = $request->{ 'request_string' };
			my @mexes = $obj->module_executions( __order => '!timestamp' );
			my $last_module_execution = $mexes[0];
			my @untypedOutputs = $last_module_execution->untypedOutputs();
			my @STs = map( $_->semantic_type, @untypedOutputs );
	    	my $first_ST = $STs[0];
			my $attributes = OME::Tasks::ModuleExecutionManager->
	    		getAttributesForMEX($last_module_execution,$first_ST);
			my $last_data_1 = $attributes->[0];
			$record{ $request_string } = $self->Renderer()->render( $last_data_1, 'ref' );
		}
	}
	# last_data_2
	if( exists $field_requests->{ 'last_data_2' } ) {
		foreach my $request ( @{ $field_requests->{ 'last_data_2' } } ) {
			my $request_string = $request->{ 'request_string' };
			my @mexes = $obj->module_executions( __order => '!timestamp' );
			my $last_module_execution = $mexes[1];
			my $ST;
			if( $last_module_execution->count_formal_outputs() == 0 ) {
				my @untypedOutputs = $last_module_execution->untypedOutputs();
				my @STs = map( $_->semantic_type, @untypedOutputs );
	    		$ST = $STs[0];
	    	} else {
				my @STs = $last_module_execution->formal_outputs();
	    		$ST = $STs[0];
	    	}
			my $attributes = OME::Tasks::ModuleExecutionManager->
	    		getAttributesForMEX($last_module_execution,$ST);
			my $last_data_2 = $attributes->[0];
			$record{ $request_string } = $self->Renderer()->render( $last_data_2, 'ref' );
		}
	}
	
	# current_annotation_author:
	if( exists $field_requests->{ 'current_annotation_author' } ) {
		foreach my $request ( @{ $field_requests->{ 'current_annotation_author' } } ) {
			my $request_string = $request->{ 'request_string' };
			my $currentAnnotation = OME::Tasks::ImageManager->
				getCurrentAnnotation( $obj );
			$record{ $request_string } = $self->Renderer()->
				render( $currentAnnotation->module_execution->experimenter(), 'ref' )
				if( ( defined $currentAnnotation ) && 
# a bug in the ACLs are not always letting the mex come through. so, hack-around
				    ( defined $currentAnnotation->module_execution ) &&
				    ( $currentAnnotation->module_execution->experimenter->id() ne 
				      $session->User()->id() )
				);
		}
	}
	# annotation_count:
	if( exists $field_requests->{ 'annotation_count' } ) {
		foreach my $request ( @{ $field_requests->{ 'annotation_count' } } ) {
			my $request_string = $request->{ 'request_string' };
			$record{ $request_string } = $factory->
				countObjects( '@ImageAnnotation', image => $obj );
		}
	}
	# annotationSTs:
	if( exists $field_requests->{ 'annotationSTs' } ) {
		foreach my $request ( @{ $field_requests->{ 'annotationSTs' } } ) {
			my $request_string = $request->{ 'request_string' };
			my @imageSTs = $factory->findObjects( 'OME::SemanticType',
				granularity => 'I'
			);
			$record{ $request_string } = $q->popup_menu(
				-name     => 'annotateWithST',
				'-values' => [ '', map( '@'.$_->name(), @imageSTs ) ],
				-default  => '',
				-labels   => { 
					'' => '-- Select a Semantic Type --', 
					map{ '@'.$_->name() => $_->name } @imageSTs 
				}
			);
		}
	}	
	# original file
	if( exists $field_requests->{ 'original_file' } ) {
		foreach my $request ( @{ $field_requests->{ 'original_file' } } ) {
			my $request_string = $request->{ 'request_string' };
			my $original_files = OME::Tasks::ImageManager->getImageOriginalFiles($obj);
			
			if( not defined $original_files ) {
				$record{ $request_string } = "No original files found";
			} elsif( ref( $original_files ) eq 'ARRAY' ) {
				my $more_info_url = 
					$self->getSearchURL( 
 						'@OriginalFile',
 						id   => join( ',', map( $_->id, @$original_files ) ),
					);
				my $zip_url = OME::Image::Server->getDownloadAllURL($obj);

				$record{ $request_string } = 
					scalar( @$original_files )." files found. ".
					"<a href='$more_info_url'>See individual listings</a> or ".
					"<a href='$zip_url'>download them all at once</a>";
			} else {
				$record{ $request_string } = 
					$self->render( 
						$original_files, 
						( $request->{ render } or 'ref' ), 
						$request 
					);
			}
		}
	}
	
	if (exists $field_requests->{ 'classificationColor'}) {
	    # if we ask for coloring by classification

	    my $cg= $options->{CategoryGroup};
	    # get the category group that was sent in
	    if ($cg) {
		# get a color and name for the classification
		my ($style,$name)  = $self->getClassificationColor($obj,$cg);
		if ($style) {
		    foreach my $request ( @ {
			$field_requests->{'classificationColor'}}) {
			# set the style

			my $request_string =  $request->{'request_string'};
			$record{$request_string} = $style;
		    }
		    foreach my $request ( @ {
			$field_requests->{'classificationName'}}) {
			# set the name
			my $request_string = $request->{'request_string'};
			$record{$request_string} = $name;
		    }
		    foreach my $request ( @ {
			$field_requests->{'linkParams'}}) {
			my $request_string =
			    $request->{'request_string'};
			$record{$request_string} = 
				    $self->getLinkParams($options,$name);
		    }
		}
	    }
	}
	return %record;
}

=head1 getClassificationColor

    my ($style,$name) = $self->getClassificationColor($obj,$cg);

    get a classification color, along with category name, for the
    given object in a given category group
=cut


sub getClassificationColor {
    my ($self,$obj,$cg) = @_;


    # get the classification
    my $classification =
	OME::Tasks::CategoryManager->getImageClassification($obj,$cg);
    return unless $classification;

    # get categories in the list.
    my @categories = $cg->CategoryList(__order => 'Name');


    my @colorList = ("red","maroon","green","purple","navy","lime",
		 "aqua","yellow","silver","blue","teal","olive");

    # map categories onto a color list
    my $color;
    my $name = $classification->Category->Name;
    foreach my $c (@categories) {
	$color = shift @colorList;
	if ($c->Name eq $name) {
	    last;
	}
    }
    #build an appropriate css tag
    my $colorString = "color: $color;";

    return ($colorString,$name);
}

sub getLinkParams {
    my ($self,$options,$name) = @_;
    my $linkParams;
    if ($options->{Template}) {
	$linkParams .= "&Template=". $options->{Template};
    }
    if ($options->{Rows}) {
	$linkParams .= "&Rows=". $options->{Rows};
    }
    if ($options->{Columns}) {
	$linkParams .= "&Columns=". $options->{Columns};
    }
    if ($options->{CategoryGroup}) {
	$linkParams .= "&CategoryGroup=". $options->{CategoryGroup}->Name;
    }
    $linkParams .= "&Category=$name";
    return $linkParams;
}
    

=head1 Author

Josiah Johnston <siah@nih.gov>

=cut

1;
