# OME/AnalysisChain.pm

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
# Written by:    Douglas Creager <dcreager@alum.mit.edu>
#
#-------------------------------------------------------------------------------


package OME::AnalysisChain;

=head1 NAME

OME::AnalysisChain - an module_execution chain

=head1 DESCRIPTION

The C<AnalysisView> class represents module_execution chains in OME.  Each
chain is a directed acyclic graph.  The nodes of the chain represent
analysis modules that must get executed.  The links of the chain
connect outputs of one node to inputs of another; they specify the
order in which modules are executed and the relationship between the
data generated by the nodes.  The nodes are represented by the
C<AnalysisView::Node> class; the links by the C<AnalysisView::Link>
class.

=cut

use strict;
use OME;
our $VERSION = $OME::VERSION;

use OME::DBObject;
use base qw(OME::DBObject);

__PACKAGE__->newClass();
__PACKAGE__->setDefaultTable('analysis_chains');
__PACKAGE__->setSequence('analysis_chain_seq');
__PACKAGE__->addPrimaryKey('analysis_chain_id');
__PACKAGE__->addColumn(owner_id => 'owner',
                       {
                        SQLType => 'integer',
                        NotNull => 1,
                        Indexed => 1,
                        ForeignKey => 'experimenters',
                       });
__PACKAGE__->addColumn(owner => 'owner','@Experimenter');
__PACKAGE__->addColumn(name => 'name',
                       {
                        SQLType => 'varchar(64)',
                        NotNull => 1,
                       });
__PACKAGE__->addColumn(description => 'description',{SQLType => 'text'});
__PACKAGE__->addColumn(locked => 'locked',
                       {
                        SQLType => 'boolean',
                        NotNull => 1,
                        Default => 'false',
                       });
__PACKAGE__->hasMany('nodes',
                     'OME::AnalysisChain::Node' => 'analysis_chain');
__PACKAGE__->hasMany('links',
                     'OME::AnalysisChain::Link' => 'analysis_chain');
__PACKAGE__->hasMany('executions',
                     'OME::AnalysisChainExecution' => 'analysis_chain');

=head1 METHODS (C<AnalysisChain>)

The following methods are available to C<AnalysisChain> in addition to
those defined by L<OME::DBObject>.

=head2 owner

	my $owner = $chain->owner();
	$chain->owner($owner);

Returns or sets the owner of this analysis chain.

=head2 name

	my $name = $chain->name();
	$chain->name($name);

Returns or sets the name of this analysis chain.

=head2 locked

	my $locked = $chain->locked();
	$chain->locked($locked);

Returns or sets whether this analysis chain is locked.

=head2 description

	my $description = $chain->description();
	$chain->description($description);

Returns or sets the description of this analysis chain.

=head2 nodes

	my @nodes = $chain->nodes();
	my $node_iterator = $chain->nodes();

Returns or iterates, depending on context, the nodes in the analysis
chain.

=head2 links

	my @links = $chain->links();
	my $link_iterator = $chain->links();

Returns or iterates, depending on context, the links in the analysis
chain.

=head2 paths

	my @paths = $chain->paths();
	my $path_iterator = $chain->paths();

Returns or iterates, depending on context, the data paths in the
analysis chain.

=cut



1;


__END__

=head1 AUTHOR

Douglas Creager <dcreager@alum.mit.edu>,
Open Microscopy Environment, MIT

=cut

