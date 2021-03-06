# OME/Project.pm

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


package OME::Project;

=head1 NAME

OME::Project - a collection of datasets

=head1 DESCRIPTION

The C<Project> class represents OME projects, which are a collection
of datasets.  Projects and datasets form a many-to-many map, as do
images and datasets.  A user's session usually has a single project
selected as the "active project".

=head1 METHODS (C<Project>)

The following methods are available to C<Project> in addition to those
defined by L<OME::DBObject>.

=head2 name

	my $name = $project->name();
	$project->name($name);

Returns or sets the name of this project.

=head2 description

	my $description = $project->description();
	$project->description($description);

Returns or sets the description of this project.

=head2 owner

	my $owner = $project->owner();
	$project->owner($owner);

Returns or sets the owner of this project.

=head2 group

	my $group = $project->group();
	$project->group($group);

Returns or sets the group that this project belongs to.

=head2 ...

	other methods exist. check out the code to see them.


=cut

use strict;
use OME;
our $VERSION = $OME::VERSION;

use Carp;

use OME::DBObject;
use base qw(OME::DBObject);

__PACKAGE__->newClass();
__PACKAGE__->setSequence('project_seq');
__PACKAGE__->setDefaultTable('projects');
__PACKAGE__->addPrimaryKey('project_id');
__PACKAGE__->addColumn(name => 'name',
                       {
                        SQLType => 'varchar(64)',
                        NotNull => 1,
                       });
__PACKAGE__->addColumn('owner_id' => 'owner_id',
                       {
                        SQLType => 'integer',
                        NotNull => 1,
                        ForeignKey => 'experimenters',
                       });
__PACKAGE__->addColumn('owner' => 'owner_id','@Experimenter');
__PACKAGE__->addColumn('group_id' => 'group_id',
                       {
                        SQLType => 'integer',
                        ForeignKey => 'groups',
                       });
__PACKAGE__->addColumn('group' => 'group_id','@Group');
__PACKAGE__->addColumn(description => 'description',{SQLType => 'text'});
__PACKAGE__->addColumn(view => 'view',{SQLType => 'varchar(64)'});

__PACKAGE__->hasMany('dataset_links','OME::Project::DatasetMap','project');
__PACKAGE__->manyToMany('datasets',
                        'OME::Project::DatasetMap','project','dataset');
__PACKAGE__->addACL({user => 'owner_id',group => 'group_id'});


# Referenced by line 412 of OME::Remote::Prototypes
sub addDataset {
    carp "DEPRECATED! Please use the ProjectManager";

	my $self = shift;
	my $dataset = shift;

	return undef unless defined $dataset;
	my $factory=$self->Session()->Factory();
	my $pdMap = $factory->findObject("OME::Project::DatasetMap",
		 dataset_id => $dataset->ID(),
		 project_id => $self->ID()
	);
	

	#my $pdMapIter = OME::Project::DatasetMap->search( dataset_id => $dataset->ID(), project_id => $self->ID() );
	#my $pdMap = $pdMapIter->next() if defined $pdMapIter;

	if (not defined $pdMap) {
		$pdMap=$factory->newObject("OME::Project::DatasetMap",{
			project_id => $self->ID(),
			dataset_id => $dataset->ID()

			} );

		#$pdMap = OME::Project::DatasetMap->create ( {
		#	project_id => $self->ID(),
		#	dataset_id => $dataset->ID()
		#} )
		#	or die ref($self)."->addDataset:  Could not create a new Project::DatasetMap entry.\n";

	}

	return $dataset;
}

1;
