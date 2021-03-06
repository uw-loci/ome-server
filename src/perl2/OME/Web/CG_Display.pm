# OME/Web/CG_Display.pm

#-------------------------------------------------------------------------------
#
# Copyright (C) 2003 Open Microscopy Environment
#       Massachusetts Institue of Technology,
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
# Written by:    Arpun Nagaraja <arpun@mit.edu>
#
#-------------------------------------------------------------------------------


package OME::Web::CG_Display;

use strict;
use Carp;
use Carp 'cluck';
use vars qw($VERSION);
use OME::SessionManager;
use OME::Tasks::AnnotationManager;
use OME::Tasks::CategoryManager;
use OME::Tasks::ModuleExecutionManager;

use base qw(OME::Web);

sub getPageTitle {
	return "OME: Display an Image";
}

{
	my $menu_text = "Display an Image";
	sub getMenuText { return $menu_text }
}

sub getTemplate {

    my $self=shift;
    my $q = $self->CGI() ;
    my $id = $q->url_param('ID');

    my $which_tmpl =  $self->getTemplateName('OME::Web::CG_Display',"&ID=".$id);

    my $tmpl =
	OME::Web::TemplateManager->getDisplayTemplate($which_tmpl);

    return $tmpl;


}
sub getPageBody {
	my $self = shift ;
	my $tmpl = shift;
	my $q = $self->CGI() ;
	my $session= $self->Session();
    	my $factory = $session->Factory();
    	my $dataset = $session->dataset();
    	my %tmpl_data;
    	my $debug;
    	my @categoryGroups;
    	my $html;

	my $id = $q->url_param('ID');
    	
	if ($tmpl ne $OME::Web::TemplateManager::NO_TEMPLATE) {		

		my $image = $factory->loadObject( 'OME::Image', $id) if ($id);

		# Load the requested category groups
		my @parameter_names = $tmpl->param();
		my @found_params = grep( m/\.load/, @parameter_names );
		my $request = $found_params[0];
		my $concatenated_request;
		my @ids;
		if( $request =~ m/\/id-\[((\d+,)*\d*)\]/ ) {
				@ids = split(/,/, $1);
		} else { 
				die "couldn't parse $request";
		}
		
		foreach my $id (@ids) {
			my $cg = $factory->loadObject( '@CategoryGroup', $id )
				or die "couldn't load CategoryGroup id: $id";
			push (@categoryGroups, $cg);
		}
		
		# Render each Category Group and Category
		my @cg_loop_data;
		my $use_cg_loop = grep{ $_ eq 'cg.loop'} @parameter_names;
		my $cntr = 1;
		foreach my $cg (@categoryGroups) {
			if ($image) {
				my $classification = OME::Tasks::CategoryManager->getImageClassification($image, $cg);
				my $category;
				$category = $classification->Category if ($classification);
				
				# If the template is using a loop, the variable names will be different
				my %cg_data;
				if( $use_cg_loop ) {
					$cg_data{ 'cg/render-ref' } = $self->Renderer()->render( $cg, 'ref')
						;#if( grep{ $_ eq 'cg/render-ref' } @parameter_names );
					if ($category) {
						$cg_data{ 'cg.cat/render-ref' } = $self->Renderer()->render( 
							$category, 'ref', { type => '@Category', class => 'ome_punchline' })
							;#if( grep{ $_ eq 'cg.cat/render-ref' } @parameter_names );
							
						#$cg_data{ 'cg.cat/Name' } = $category->Name
						#	if( grep{ $_ eq 'cg.cat/Name' } @parameter_names );
					} else {
						$cg_data{ 'cg.cat/render-ref' } = "<i>Unclassified</i>"
							 ;#if( grep{ $_ eq 'cg.cat/render-ref' } @parameter_names );
							 
						#$cg_data{ 'cg.cat/Name' } = "<i>Unclassified</i>"
							 #if( grep{ $_ eq 'cg.cat/Name' } @parameter_names );
					}
					
					push( @cg_loop_data, \%cg_data );
				} else {
					# The greps are used to see if the user actually wants
					# the variables in question. It is not used in the loop
					# because the variables are not in the list of parameters.
					# FIXME!
					$tmpl_data{ 'cg['.$cntr.']/render-ref' } = $self->Renderer()->render( $cg, 'ref')
						if( grep{ $_ eq 'cg['.$cntr.']/render-ref' } @parameter_names );
						
					if ($category) {
						$tmpl_data{ 'cg['.$cntr.'].cat/render-ref' } = $self->Renderer()->render( 
							$category, 'ref', { type => '@Category', class => 'ome_punchline' }
						) if( grep{ $_ eq 'cg['.$cntr.'].cat/render-ref' } @parameter_names );
						
						$tmpl_data{ 'cg['.$cntr.'].cat/Name' } = $category->Name
							if( grep{ $_ eq 'cg['.$cntr.'].cat/Name' } @parameter_names );
					} else {
						$tmpl_data{ 'cg['.$cntr.'].cat/render-ref' } = "<i>Unclassified</i>"
							 if( grep{ $_ eq 'cg['.$cntr.'].cat/render-ref' } @parameter_names );
							 
						$tmpl_data{ 'cg['.$cntr.'].cat/Name' } = "<i>Unclassified</i>"
							 if( grep{ $_ eq 'cg['.$cntr.'].cat/Name' } @parameter_names );
					}
				}
			}
			$cntr++;
		}
		$tmpl_data{ 'cg.loop' } = \@cg_loop_data if( $use_cg_loop );
		
		my @image_requests = grep( m'^image/render-(\w+)$', @parameter_names )
			or die "no image requested";
		my $image_request = @image_requests[0];
		$image_request =~ m'^image/render-(\w+)$';
		my $mode = $1;
		$tmpl_data{ $image_request } = $self->Renderer()->render( $image, $mode);
		$tmpl->param( %tmpl_data );
	}
	
	# render the dropdown list of available templates, and if they select
	# one, refresh the page with that param in the URL
	my $templates =  OME::Web::TemplateManager->getImageDisplayTemplates();
#$factory->findObjects('@DisplayTemplate', { ObjectType =>
#'OME::Image', Arity => 'one' } ); 
# 		my @user_templates;
# 		foreach my $tmpl_attr (@templates) {
# 			my $mexes = OME::Tasks::ModuleExecutionManager->getMEXesForAttribute($tmpl_attr);
# 			my $mex = @$mexes[0];
# 			my $tmp = $mex->{'__fields'}->{'module_executions'}->{'module_id'};
# 			$debug .= join("<br>", keys(%$tmp))."<br><br><br>";
# 		}
	my $popup;
	my $button;
	my $url = $self->pageURL('OME::Web::CG_Display');
	my $createURL = $self->pageURL('OME::Web::CG_ConstructTemplate');
	my $directions = "<i>There are no templates in the database. <a href=\"$createURL\">Create a template</a><br><br>
						 If you already have templates in your Browse, Actions/Annotator, or Display/One/OME/Image
						 directory,<br>from the command line, run 'ome templates update -u all'</i>";

	if ( scalar(@$templates) > 0 ) {
		$directions = "Current template:<br>";
		$popup = $q->popup_menu(
							-name     => 'Templates',
							'-values' =>  [ map( $_->Name, @$templates) ],
							-labels   =>  { map{ $_->Name => $_->Name } @$templates },
							-default  => $q->url_param('Template'));
		$button = $q->submit (
						-name => 'LoadTemplate',
						-value => 'Load'
					 );
					 
		return ('REDIRECT', $self->redirect($url.'&ID='.$id.'&Template='.$q->param( 'Templates' ))) if ($q->param( 'LoadTemplate' ));
	}
	
	$html =
		$debug.
		$q->startform( { -name => 'primary' } ).
		$directions.
		$popup.
		$button;
	
	$html .= $tmpl->output() if ($tmpl &&
		     $tmpl ne $OME::Web::TemplateManager::NO_TEMPLATE);

	$html .= $q->endform();

	return ('HTML',$html);
	
}

1;
