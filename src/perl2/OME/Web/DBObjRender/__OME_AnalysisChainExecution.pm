# OME/Web/DBObjRender/__OME_AnalysisChainExecution.pm
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


package OME::Web::DBObjRender::__OME_AnalysisChainExecution;

=pod

=head1 NAME

OME::Web::DBObjRender::__OME_AnalysisChainExecution

=head1 DESCRIPTION

Provides custom behavior for rendering an OME::AnalysisChainExecution

=head1 METHODS

=cut

use strict;
use OME;
our $VERSION = $OME::VERSION;

use Carp 'cluck';
use base qw(OME::Web::DBObjRender);

=head2 _renderData

makes virtual fields breakdown_by_node

=cut

sub _renderData {
	my ($self, $obj, $field_requests, $options) = @_;
	
	my $factory = $obj->Session()->Factory();
	my %record;

	# thumbnail url
	if( exists $field_requests->{ 'breakdown_by_node' } ) {
		foreach my $request ( @{ $field_requests->{ 'breakdown_by_node' } } ) {
			my @nodes = $obj->analysis_chain->nodes();
			# FIXME: Original Files and Image import never show up in the chain.
			# When that underlying problem is fixed, this grep should be removed.
			@nodes = grep( 
				($_->module->name ne 'Original files' && 
				$_->module->name ne 'Image import' ),
				@nodes
			);
			my @node_execution_links = map( 
				"<a href='".
				$self->pageURL( 'OME::Web::Search', {
					Type                     => 'OME::AnalysisChainExecution::NodeExecution',
					analysis_chain_node      => $_->id,
					analysis_chain_execution => $obj->id
				} ).
				"' title='View Executions of this node'>".
				$_->module->name."</a>",
				@nodes
			);
			my $request_string = $request->{ 'request_string' };
			$record{ $request_string } = join( ', ', @node_execution_links );
		}
	}
	
	return %record;
}

=head1 Author

Josiah Johnston <siah@nih.gov>

=cut

1;