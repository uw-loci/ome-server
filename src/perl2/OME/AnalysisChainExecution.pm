# OME/AnalysisChainExecution.pm

##-------------------------------------------------------------------------------
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


package OME::AnalysisChainExecution;

=head1 NAME

OME::AnalysisChainExecution - execution of an module_execution chain

=head1 DESCRIPTION

The C<AnalysisChainExecution> class represents an execution of an OME
analysis chain against a dataset of images.  The
C<AnalysisChainExecution::NodeExecution> class represents an execution of
each node in the chain.  Each actual execution of the chain is
represented by exactly one C<AnalysisChainExecution>, and each execution of
a node is represented by exactly one
C<AnalysisChainExecution::NodeExecution>, even if the results of a module
execution are reused.

=cut

use strict;
use OME;
our $VERSION = $OME::VERSION;

use OME::DBObject;
use base qw(OME::DBObject);

__PACKAGE__->newClass();
__PACKAGE__->setDefaultTable('analysis_chain_executions');
__PACKAGE__->setSequence('analysis_chain_execution_seq');
__PACKAGE__->addPrimaryKey('analysis_chain_execution_id');
__PACKAGE__->addColumn(analysis_chain_id => 'analysis_chain_id');
__PACKAGE__->addColumn(analysis_chain => 'analysis_chain_id',
                       'OME::AnalysisChain',
                       {
                        SQLType => 'integer',
                        NotNull => 1,
                        Indexed => 1,
                        ForeignKey => 'analysis_chains',
                       });
__PACKAGE__->addColumn(dataset_id => 'dataset_id');
__PACKAGE__->addColumn(dataset => 'dataset_id','OME::Dataset',
                       {
                        SQLType => 'integer',
                        NotNull => 1,
                        Indexed => 1,
                        ForeignKey => 'datasets',
                       });
__PACKAGE__->addColumn(status => 'status',
					   {
					   	SQLType => 'varchar(16)'
					   });
__PACKAGE__->addColumn('timestamp' => 'timestamp',
                       {
                        SQLType => 'timestamp',
                        Default => 'CURRENT_TIMESTAMP',
                       });
__PACKAGE__->addColumn(experimenter_id => 'experimenter_id',
                       {
                        SQLType => 'integer',
                        NotNull => 1,
                        Indexed => 1,
                        ForeignKey => 'experimenters',
                       });
                       
__PACKAGE__->addColumn(task => 'task','OME::Task',
                       {
                        SQLType => 'integer',
                        ForeignKey => 'tasks',
                       });
__PACKAGE__->addColumn(results_reuse => 'results_reuse',
                       {
                        SQLType => 'boolean',
                        NotNull => 1,
                        Default => 'false',
                       });
__PACKAGE__->addColumn(additional_jobs => 'additional_jobs',
                       {
                        SQLType => 'boolean',
                        NotNull => 1,
                        Default => 'false',
                       });
__PACKAGE__->addColumn(experimenter => 'experimenter_id','@Experimenter');
__PACKAGE__->hasMany('node_executions',
                     'OME::AnalysisChainExecution::NodeExecution' =>
                     'analysis_chain_execution');
__PACKAGE__->addACL ({
        	user    => 'experimenter_id',
        	group   => 'acl.group_id',
        	froms   => ['experimenters acl'],
        	wheres  => ["acl.attribute_id = experimenter_id"],
        	});
# timing information column
__PACKAGE__->addColumn(['total_time', 't_time'] => 't_time',
                       {SQLType => 'float'});
                       
=head1 METHODS (C<AnalysisChainExecution>)

The following methods are available to C<AnalysisChainExecution> in
addition to those defined by L<OME::DBObject>.

=head2 analysis_chain

	my $analysis_chain = $execution->analysis_chain();
	$execution->analysis_chain($analysis_chain);

Returns or sets the analysis chain which was executed.

=head2 dataset

	my $dataset = $execution->dataset();
	$execution->dataset($dataset);

Returns or sets the dataset that the chain was executed against.

=head2 experimenter

	my $experimenter = $execution->experimenter();
	$execution->experimenter($experimenter);

Returns or sets the experimenter who performed the execution of the
chain.

=head2 timestamp

	my $timestamp = $execution->timestamp();
	$execution->timestamp($timestamp);

Returns or sets when the execution occurred.

=head2 node_executions

	my @nodes = $execution->node_executions();
	my $node_iterator = $execution->node_executions();

Returns or iterates, depending on context, a list of all of the
C<AnalysisChainExecution::NodeExecutions> associated with this chain
execution.

=cut



1;

__END__

=head1 AUTHOR

Douglas Creager <dcreager@alum.mit.edu>,
Open Microscopy Environment, MIT

=cut

