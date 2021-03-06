# There is no shebang line b/c this file should be eval'ed.

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
# Written by:  Douglas Creager <dcreager@alum.mit.edu>
#-------------------------------------------------------------------------------

# Contains the DTO description for a user's session state

%class_description = (
                      Package => 'org.openmicroscopy.ds.dto',
                      Class   => 'UserState',

                      ImportPackages =>
                      {
                       'org.openmicroscopy.ds.st' =>
                       ['Experimenter','ExperimenterDTO']
                      },

                      Fields  =>
                      [
                       ID              => ['int'],
                       Experimenter    => ['Experimenter'],
                       Host            => ['String'],
                       Project         => ['Project'],
                       Dataset         => ['Dataset'],
                       ModuleExecution => ['ModuleExecution',
                                           'module_execution'],
                       ImageView       => ['String','image_view'],
                       FeatureView     => ['String','feature_view'],
                       LastAccess      => ['String','last_access'],
                       Started         => ['String'],
                      ],
                     );
