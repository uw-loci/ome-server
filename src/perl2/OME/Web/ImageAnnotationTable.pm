# OME/Web/ImageAnnotationTable.pm
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
# Written by:    Harry Hochheiser <hsh@nih.gov>
#                Ilya Goldberg <igg@nih.gov>
#                  * Added ability to specify hierarchies without mapping types (one-to-many)
#                  * Moved several options into template parameters, and clenaed up format.
#
#-------------------------------------------------------------------------------

package OME::Web::ImageAnnotationTable;

=head1 NAME

OME::Web::ImageAnnotationTable - An OME page displaying a table of
    images as annotated in one or more hierarchies.

=head1 DESCRIPTION

    Analysis and interpretation of annotated images often requires
    displays tailored to specific experimentals. 

    Images from WISH screens of pre-implementation mouse embryos
    (Yoshikawa, et al., Gene Expression Patterns 6(2), January 2006)
    involve categorization of images by genes and associated probes
    (on the one hand) and stage of embryonic development (on the other). 

    Given these annotations, images can be displayed in  grid, with
    development stages as the columns and genes/probes forming the
    rows (Yoshikawa, et al., Figure 3). 

    ImageAnnotationTable is an OME::Web page that supports this
    layout. Furthermore, for any given grid construction, images
    within a cell can be color-coded on the basis of values from a
    specified category group.

=head1 USAGE
    
    This page can be served via the usual OME dispatcher. Parameters
    needed for proper execution include:


    Template=GeneProbeTable:  - the name of an instance of the
    AnnotationTemplate semantic type. This intance must refer to an
    HTML::Template file that has a specification of the types that
    will be used to populate the output of the table. This
    specification will take the form described in the "TYPE
    SPECIFICATION" section below.


    Rows=Gene, Columns=EmbryoStage: These parameters will specify the
    root types to be used for the rows and columns of the output
    table. These names must correspond to the initial values given in
    the "Path.load/types" specification lists. 
    
    If Rows and Columns are both specified,  the information will be
    placed in a 2-dimensional table. If only Rows are specified, a
    one-d list of rows will be presented. A value for Rows is
    required, but a value for Columns is optional.

    
    CategoryGroup=Localization: the category group used for
    color-coding of the images. Note that no color-coding will be used
    if this value is left unspecified.


=head1 TYPE SPECIFICATION


    The template must contain at least two entries of the form 

    <TMPL_VAR NAME="Path.load=[Gene Manipulation]Gene.Name:GeneticManipulation.Type(ImageGeneticManipulation)">

	Each of these specifies a hierarchy to be used as an axis in the table - rows and columns.
	The text in square brackets ([]) is used as a label for this hierarchy or path.
	Each item in the path is separated by ':'.  The last item, which must be an Image attribute, is
	surrounded by parentheses.  Each item in the path must also be connected to its neighbors with
	references:  GeneticManipulation has a reference to Gene.  ImageGeneticManipulation has a
	reference to GeneticManipulation, so GeneticManipulation is connected to both Gene and to
	ImageGeneticManipulation.  These objects have direct connections.  It is also possible to specify
	connections using mapping objects.  Mapping objects are listed as path items without fields, and
	they will not appear in the table, though they will obviously be used in the queries that generate it.
	The example below illustrates a hierarchy connected using mapping objects:

    <TMPL_VAR NAME="Path.load=[Gene-Probe]Gene.Name:ProbeGene:Probe.Name(ImageProbe)">
	
	Both of these examples use a two-level hierarchy on a single axis because they contains two object.field
	specifications, each of which will be expanded in the table.
    Parenthesized types are types that map from the given type to images: thus, ImageProbe
    relates Probes to Images.  

    In the Gene:ProbeGene:Probe(ImageProbe) example, the ProbeGene
    relationship is essentially a many-to-one: one gene can have many
    probes, but a given probe is generally associated with only  one
    gene.  Thus, given a set of genes (or all genes in the database),
    this path of types, together with the ImageProbe map, is
    sufficient for fully-specifying a query for a set of images.

    In other cases, this specification might not be so clear.

    For example, worm annotation models might have types that
    describe location within the worm, the experimental strain, and
    the age of the worm (in days).  Locations and strains might have a
    many-to-many relationship, thus the strain itself is not
    sufficient for identifying appropriate images. In effect, we need
    to find images that have a given location and have a given strain.
    This can be accomplished by providing mapping types from both
    locations and strains to images, as follows:

    <TMPL_VAR NAME="Path.load=[Worm-Location]WormLocation(ImageWormLocation):
         WormLocationStrain:Strain(ImageStrain)">

=cut


use strict;
use Carp;
use Carp 'cluck';
use vars qw($VERSION);
use OME::SessionManager;
use base qw(OME::Web);
use Time::HiRes qw(gettimeofday tv_interval);
use OME::Web::TemplateManager;
use Data::Dumper;

my $NO_COLS='__NONE__';

sub new {
    my $proto =shift;
    my $class = ref($proto) || $proto;
    my $self = $class->SUPER::new(@_);
    
    # some private variables
    # the names for the rows, columns, and category group
    $self->{rows}="";
    $self->{columns}="";
    $self->{CategoryGroup}="";
    $self->{Category}="";
    $self->{Template} ="";
    # the actual rows and columns
    $self->{rowEntries} = undef;
    $self->{colEntries} = undef;
    # How many rows to show at once.
    $self->{rowLimit}   = 10;
    #  mapping types from annotation sts to images.
    $self->{ImageMaps}  = undef;
    # Any image filters specified by the template.
    $self->{filters}  = {};
    # Row/Column Menus enabled
    $self->{HasRowColumnChoice}  = 0;
    # Row/Column Menus enabled
    $self->{HasCategories}  = 1;
    


    # value chosen for the row.
    $self->{rowValue}  = undef;
    # has the row been switched?
    $self->{rowSwitch} = 0;

    # page to return to.
    $self->{returnPage} = undef;
    return $self;
}

sub getPageTitle {
    return "OME: Image Annotation Table";
}

{
    my $menu_text = "Image Annotation Table";
    sub getMenuText { return $menu_text }
}

sub getTemplate {

    my $self=shift;
    
    my $which_tmpl =  $self->getTemplateName('OME::Web::ImageAnnotationTable');
    my $tmpl =
	OME::Web::TemplateManager->getBrowseTemplate($which_tmpl);
	die "Could not load template $which_tmpl" unless $tmpl;
    return $tmpl;


}


=head2 getPageBody
    
=cut


sub getPageBody {
    my $self = shift ;
    my $tmpl = shift;
    my $q = $self->CGI() ;
    my $session= $self->Session();
    my $factory = $session->Factory();

    # Load the correct template and make sure the URL still carries
    # the template  name.
    # get template from url parameter, or referer





    # get the details. this is where the bulk of the work gets done.
    # use this procedure to allow for bulk of layout to be called from
    # other modules
    my $output = $self->getTableDetails($self,$tmpl,
					'OME::Web::ImageAnnotationTable');


    # and the form.
    my $html =
	$q->startform( { -name => 'primary' } );
    $html .= $output;
    $html .= $q->endform();

    return ('HTML',$html);	
}

=head2 getTableDetails

    my $output = $self->getTableDetails($container,$which_tmpl,$returnPage);

    getTableDetails does the meat of the work of building this page.
    We load the template, populate pull-downs that let us switch x and
    y axes, and render the various dimensions.

    $container is the object that calls this code. 
    $which_tmpl is the template that we are populating
    $returnPage is the page that will be returned to when we click on
      category group labels.
    
    
    
=cut

sub getTableDetails {
    my $self = shift;

    my $session= $self->Session();
    my $factory = $session->Factory();


    my $start = [gettimeofday()];
    # container is the OME::Web object that is calling this code.
    my ($container,$tmpl,$returnPage) = @_;
    my $q = $container->CGI();
    $self->{Template}=$q->param('Template');
    $self->{returnPage} = $returnPage;
    my %tmpl_data;


    # figure out what we have for rows and columns
    # This will get $self->{filters}, $self->{rows} and $self->{columns}
    my $types = $self->getTmplParams($tmpl);

  #  print STDERR" *** types are ***\n";
#    print STDERR Dumper($types);
#    print "\n\n";
    # if the value of Rows or Columns is 'None', don't set the values
    # - leave them undefined.
    
    if ($q->param('Rows') && $q->param('Rows') ne 'None') {
		$self->{rows} = $q->param('Rows');
		$tmpl_data{'rowFieldName'} = $self->{rows};
    }
    elsif ($q->param('Rows') && $q->param('Rows') eq 'None') {
		$self->{rows} = undef;
		$tmpl_data{'rowFieldName'} = "Rows";
    }
    else {
		$tmpl_data{'rowFieldName'} = $self->{rows};
    }

    if ($q->param('Columns') && $q->param('Columns') ne 'None') { 
		$self->{columns} = $q->param('Columns');
    } elsif ($q->param('Columns') && $q->param('Columns') eq 'None') {
		$self->{columns} = undef;
    }
    # set the 'prevRows' field in the template to be equalto hat i
    # specify for the rows. If there is a value for prevRows in the
    # CGI, and it's not what i've just selected, 
    # set rowSwitch to 1. This will indicate that the row value has
    # been changed.
    $tmpl_data{'prevRows'} = $self->{rows};
    if ($q->param('prevRows') && $self->{rows} ne
	$q->param('prevRows')) {
	$self->{rowSwitch} =1;
    }



    # populate the pull-downs.

    if ($self->{HasRowColumnChoice}) {
	$self->getChoices(\%tmpl_data,$types);
    }

    if ($self->{HasCategories}) {
	$tmpl_data{'categoryGroups/render-list_of_options'}=
	    $self->getCategoryGroups($container);
	
	$tmpl_data{'categories/render-list_of_options'} = 
	    $self->getCategories($container);
	$tmpl_data{HasCategories} = $self->{HasCategories};
    }

    # timer stuff.
    my $elapsed = tv_interval($start);
    $start = [gettimeofday()];
    if (!$q->param('Base')) {
	if ($self->{rows}) {
	
	    if ($self->{columns} && $self->{rows} eq $self->{columns}) {
		$tmpl_data{errorMsg}="You must choose different values for rows and columns\n";
	    }
	    else {
		# do the bulk of the work.

		my $hasData =
		    $self->renderDims($container,\%tmpl_data,$types);

		# set the input field for the row value.
		# Essentially, we want to populate that text field
		# with the right value if (a) a value has been given
		# and (b) the Type used for the rows has not
		# changed. Case (b) can be further broken down to two
		# cases: if there is no previous row, it has not
		# changed. If there is, and it is not equal to the
		# current row, then it has changed, and the input
		# field should be left blank, by not setting the
		# template variable. 
		if ($self->{rowValue}) {
		    if ($q->param('prevRows')&& 
			($self->{rows} eq $q->param('prevRows'))) {
			$tmpl_data{'rowValue'} = $self->{rowValue};
		    }
		    else {
			$tmpl_data{'rowValue'} = $self->{rowValue};
		    }
		}
		if ($hasData == 0) {
		    $tmpl_data{errorMsg}="No Data to Render\n";
		}
	    }
	}
	else {
	    # return n error message if no row has been provided.
	    $tmpl_data{errorMsg}="Please specify a type to be used in the rows of the table.\n";
	}
    }
    $tmpl->param(%tmpl_data);
    return $tmpl->output();
}


=head2

    my $types = $self->getTmplParams($tmpl);

    get Types for the template. For a gievn template, 
    finds the TMPL_VARS given in a  Path.load/types-[..] format. 
    
    this will be a list of paths, separated by commas.
    ecach path will be a colon-separated path of types leading from
    some root to a map that refers to an image.

    thus, 
    Path.load=[Gene-Probe]Gene.Name:ProbeGene:Probe.Name(ImageProbe)
    Path.load=[Genetic Manipulation]Gene.Name:GeneticManipulation.Type(ImageGeneticManipulation)
    Path.load=EmbryoStage.Name(ImageEmbryoStage)
                     

    defines three dimensions.

    The result of this call will be a hash. The keys to the hash will
    be the first entries (the roots) in each of the dimension paths.

    
    For each key, the value will be the completely specified array of
    path objects.
    Thus, for the above example, we will have the following result:

    {
      'Gene-Probe' =>  ['Gene.Name','ProbeGene','Probe.Name'],
      'Genetic Manipulation' => ['Gene.Name','GeneticManipulation.Type'],
      'EmbryoStage' => ['EmbryoStage.Name'] }

    {
  
    The return value is the reference to the hash.
    
    Additional template parameters are:
    Filter.load/ImageAttributeList.AttributeElement:value
    Thus,
    Filter.load/PublicationStatusList.Publishable:1
    will only display images that have PublicationStatusList.Publishable set to true.
    
    
    DefaultRow.load/Key=Gene-Probe
    DefaultColumn.load/Key=EmbryoStage
    Sets the default Row and Column (unless specified in the query/form) to one of the
    dimension labels defined above.  Note that there can be different paths
    from a given root to an image object, so path labels must be used to distinguish them.
    
    RowColumnMenu.load/Enabled=1
    Enables display of Row/Column menu (disabled by default)
    CategoriesMenu.load/Enabled=0
    Enables display of the Categories menu (enabled by default)
    
=cut

sub getTmplParams {

    my $self= shift;
    my $tmpl = shift;
    my @parameters = $tmpl->param();
    my @default_params = grep (m/Default(Column|Row)\.load\//,@parameters);
    my @menu_params = grep (m/Menu\.load\//,@parameters);
    my @filt_params = grep (m/Filter\.load\//,@parameters);
    my @types_params  = grep (m/Path\.load=/,@parameters);
    my $typesParamCount = scalar(@types_params);
    my %pathSet;
# 	print STDERR "types_params parameters...\n";
# 	print STDERR Dumper(@types_params);
# 	print STDERR "\n";
    
    
    foreach my $def (@default_params) {
    	$self->{columns} = $1 if $def =~ /Column\.load\/Key=(.+)$/;
    	$self->{rows} = $1 if $def =~ /Row\.load\/Key=(.+)$/;
    }
    foreach my $menu (@menu_params) {
    	$self->{HasRowColumnChoice} = 1 if $menu =~ /RowColumnMenu\.load\/Enabled=1/;
    	$self->{HasCategories} = 0 if $menu =~ /CategoriesMenu\.load\/Enabled=0/;
    }
    foreach my $filt (@filt_params) {
    	$self->{filters}->{$1} = $2 if $filt =~ /Filter\.load\/([^:]+):(.+)$/;
    }

    # iterate over the types params in order
    foreach my $type (@types_params) {
		# find the path label and value.
		my ($label,$path) = ($2,$3) if ($type =~ m/Path.load=(\[([^\]]+)\])?(.*)$/);
#    print STDERR "path $type: $label = $path\n";

	    my @entries = split (/:/, $path);
	    my @parsedEntries;
	    
	    foreach my $entry (@entries) {
	    	# Entries are either a bare object name or an object name and a field (i.e. Object.Field).
	    	# Entries that specify a field are assumed to be "splitting" fields, which means the field values
	    	# will be displayed as rows or columns.
	    	# Entries without a field are assumed to be pure mapping objects.

			# this regex checks to see if the entry
			# looks like foo(bar) - a specification of a type
			# along  with a mapping type to an image.
			# if there is a match, the type becomse $1
			# and the mapping type $2.  Put the type into the 
			# resulting list, and create an appropriate map for
			# that type. Otherwise, just use the type as specified.
			if ($entry =~ /(.*)\(([^)]*)\)/ )  {
				$entry = $1;
				$self->{ImageMaps}->{$1} = $2;
#print STDERR "ImageMaps $1 = $2\n";
			}
			my ($object,$field) = split (/\./,$entry);
			# Set the label if there isn't one yet.
			$label = $object unless $label;
			# Push the object and field onto the list.
			push (@parsedEntries,$entry);
	    }
	    $pathSet{$label} = \@parsedEntries;
	}
    # return ref to array of refs.
#     print STDERR "pathSet...\n";
#     print STDERR Dumper(\%pathSet);
#     print STDERR "\n";
    return \%pathSet;
}

=head2 getChoices

    $self->getChoices(\%tmpl_data,$types);

    getChoices populates the Columns and Rows pull-down menus in the
    template. This is done by iterating down the root types for each
    of the dimensions and putting them     into the template
    variable. 

    If something matching the "Rows" or "Columns" parameter is found,
        set that value to be selected
        
=cut

sub getChoices {
    my $self=shift;
    my $tmpl_data = shift;
    my $types = shift;

    my @rows;

    my @columns;
    
    my $rows= $self->{rows};
    my $cols = $self->{columns};

    foreach my $type (keys %$types) {
	# clear off header if it's an st
		my %row;
		my %col;
		$row{rowName} = $type;
		if ($type eq $rows) {
	 	   $row{selectedRow} = 1;
		}

		push(@rows,\%row);
		$col{columnName} = $type;
		if ($cols && $type eq $cols) {
		    $col{selectedCol} = 1;
		}
		push (@columns,\%col);
    }

    $tmpl_data->{Columns}=\@columns;
    $tmpl_data->{Rows}=\@rows;
    $tmpl_data->{HasRowColumnChoice} = $self->{HasRowColumnChoice};
}

=head2 prepareCategoryGroups 
    $cgs = $self->getCategoryGroups($container);

    prepare and populate the category groups parameter and pull-down 

=cut

sub getCategoryGroups {

    my $self=shift;
    my $container = shift;
    my $session= $self->Session();
    my $factory = $session->Factory();
    my $q = $container->CGI();

    # do the list of categories
    my $cgParam = $q->param('CategoryGroup');
    my %cgHash;

    # set up hash to describe rendering. 
    $cgHash{type} = '@CategoryGroup';
    my $cg;
    if ($cgParam) {
	if ($cgParam =~ /\D+/) { # not numbers
	    $cg = $factory->findObject('@CategoryGroup',Name=>$cgParam);
	    if ($cg) {
		$self->{CategoryGroup} = $cg;
		$cgHash{default_value} = $cg->id();
	    }
	}
	else {
	    # $cgParam is now the id of a cg.
	    my  $cg =
		$factory->loadObject('@CategoryGroup',$cgParam);
	    if ($cg) {
		$self->{CategoryGroup} = $cg;
		$cgHash{default_value} = $cgParam;
	    }
	}
    }

    my @catGroupList = $factory->findObjects('@CategoryGroup');
    my $renderer=  $container->Renderer;
    my $cats =
	$renderer->renderArray(\@catGroupList,'list_of_options', 
				     \%cgHash);
    return $cats;
}

=head2 getCategories

    Populate the pull-down with individaul category value.

=cut


sub getCategories {

    my $self=shift;
    my $container = shift;
    my $session= $self->Session();
    my $factory = $session->Factory();
    my $q = $container->CGI();

    # do the list of categories
    # nothing specified for Category if 'All' was selected 
    my $category = $q->param('Category');
    if ($category && $category eq 'All')  {
	$self->{Category} = undef;
    }
    # get the group.
    my $group = $self->{CategoryGroup};

    # do nothing if no group specified.
    return undef unless ($group);
    my %catHash;

    # set up hash to describe rendering. 
    $catHash{type} = '@Category';

    # load the category, either by Id or string.
    my $cat;
    if ($category) {

	if ($category =~ /\D+/) { # string, not number
	    $cat = $factory->findObject('@Category',Name=>$category);
	}
	else { # $category is an id
	    $cat = $factory->loadObject('@Category',$category);
	}
    }

    # find the categories for the group.
    my @catList = $factory->findObjects('@Category',
					{CategoryGroup =>
						 $group});
    # category can only be set if it's valid for this group. To see if
    # that is the case, we must go through the list of categories
    # to see if i can find my category. if I find it, set the default
    # value of the hash.
    if ($cat) {
	foreach my $catEntry  (@catList) {
	    if ($catEntry->id == $cat->id) {
		    $self->{Category} = $cat;
		    $catHash{default_value} = $cat->id;
		    last;
	    }
	}
    }
    my $renderer=  $container->Renderer;
    my $cats =
	$renderer->renderArray(\@catList,'list_of_options', 
				     \%catHash);
    return $cats;
}

=head2 renderDims

    my $hasData = $self-renderDims($container,\%tmpl_data,$types);
    
    The main rendering code. Parameters are the container in which
    this is being executed, the template being populated, and the
    types hash as returned from getTmplParams.

    Return value is true if data is found, else false

=cut

sub renderDims {
    my ($self, $container, $tmpl_data, $types) = @_;
    my $session= $self->Session();
    my $factory = $session->Factory();
    my $q = $container->CGI();
    my $rows = $self->{rows};
    my $columns = $self->{columns};
    my $hasData = 0;
    my $root;

    
    # firt, we find the objects that we're rendering in the rows
    # this is either all of the objects specified by the "Rows" CGI
    # parameter, or it is a list of specific values.
    my $start = [gettimeofday()];
    my $rowPath = $types->{$rows};
    ($root,$self->{rowEntries}) =
		$self->getObjects($container,$rows,$rowPath);
    $self->{rowValue} = $root if ($root);

    # same for columns.
    my $colPath;
    $colPath = $types->{$columns} if ($columns);
 #   print STDERR " columns is $columns.\n";
#    print STDERR " colpath is \n";
#    print STDERR Dumper($colPath);
    
    ($root,$self->{colEntries}) = 
		$self->getObjects($container,$columns,$colPath);
 #   print STDERR "column entries...\n";
  #  print STDERR Dumper($self->{colEntries}) . "\n";

    my $elapsed = tv_interval($start);
    $start      = [gettimeofday()];    
    # populate the cells with data in a hash.
    # activeRows returns a list of rows that have data,
    # active cols indicates columns
    my ($cells,$activeRows,$activeCols) =
		$self->populateCells($types);

	# Implement paging of the rows
	if( $self->{rowLimit} ) {
		# Make a list of primary rows (ex. one row per-gene rather than one row per-probe)
		my %primaryIDs;
		my @primaryRows;
		foreach my $row ( @$activeRows ) {
			if( !exists( $primaryIDs{ $row->[0] } ) ) {
				$primaryIDs{ $row->[0] } = scalar( @primaryRows );
			}
			push( @{ $primaryRows[ $primaryIDs{ $row->[0] } ] }, $row );
		}
		
		# Apply paging to the primary rows
		my $objCount = scalar( @primaryRows );
		my ($offset, $pager_text ) = $self->Renderer()->_pagerControl( 'RowPager', $objCount, $self->{rowLimit} );
		@primaryRows = splice( @primaryRows, $offset, $self->{rowLimit} );
		$tmpl_data->{ pager_text } = $pager_text;
		
		# Convert that paging to the secondary rows
		$activeRows = [];
		foreach my $primaryRow( @primaryRows ) {
			push( @$activeRows, @$primaryRow );
		}
		
		# Alternately, one could use the code below to page over the secondary rows.
#		my $objCount = scalar( @$activeRows );
#		my ($offset, $pager_text ) = $self->Renderer()->_pagerControl( 'RowPager', $objCount, $self->{rowLimit} );
#		$activeRows = [ splice( @$activeRows, $offset, $self->{rowLimit} ) ];
#		$tmpl_data->{ pager_text } = $pager_text;
	}



    $elapsed = tv_interval($start);
    $start   = [gettimeofday()];    
    # if any data, populate the template
    if ($cells) {
		$hasData=1;
	
		# # of columns is the number of active columns + the 
		# number of columns needed for row paths..
		my $rowEntrySize = $self->getHeaderSize($self->{rowEntries});
		$tmpl_data->{rowHeaderCount} = $rowEntrySize;
		
		# populate the headers of the columns
		my $cHeaders = 
			$self->populateColumnHeaders($container,$activeCols,
						 $rowEntrySize,$colPath);
		$elapsed = tv_interval($start);
		$start = [gettimeofday()];    
		$tmpl_data->{columnHeaders} =$cHeaders if ($cHeaders);
	
		# do the body.
	
		my $body =
			$self->populateBody($container,$cells,$activeRows,
					$activeCols,$rowPath);
		$tmpl_data->{cells}=$body;
    }
    $elapsed = tv_interval($start);
    return $hasData;
}

=head2 

    $self->{rowEntries} =
          $self->getObjects($container,$rows,$rowPath);

    getObjects gets the objects of interest for a given hierarchy.
    Given a container, a  type (Probe,EbmbryoStage, etc.), and a path
    that maps  that type to something that eventually maps to images,
    find the objects that     are of interest.

    There are two possibilities. If there is a CGI parameter
    corresponding to the input type - (ie., if Type=Probe and there is
    a CGI parameter Probe=...), take the values given in that CGI
    parameter and use them to identify the root set. Otherwise, find
    all objects of the given root type.

    As the type specification given in the $paths argument can contain
    an arbitray list of types leading from some root down to the
    leaves, getObjects returns an array of paths. Each path is itself
    an array, with the first element being the name of the root object being
    searched for, and subsequent elements being names of objects along
    the way to the atual root object, whih is the last item in the
    array.

    If The Type  value is not specified, we have a situation where the
    column value has not been provided (upstream code prevents row
    from being unspecified). In this case, return an array with the
    single enry $NO_COLS. This will later be used as a flag to
    determine  how columns are handled.
    

=cut

sub getObjects {
    my ($self, $container, $type, $paths) = @_;
    my $session = $self->Session();
    my $factory = $session->Factory();
    my $q = $container->CGI();

#     print  STDERR "getting type for $type.  paths:\n";
# 	print STDERR Dumper($paths). "\n";

    if (!$type) { # if no type is specified, return a special
		  # indicator
		my @res = ($NO_COLS);
		return (undef,\@res);
    }

    # load the type
    my ($STName,$SEName) = split (/\./, $paths->[0]);
#    print  STDERR "got $STName,$SEName for $paths->[0]\n";
    my $typeST = $factory->findObject('OME::SemanticType',{name=>$STName});
    # get root vaalue
    my $root = $q->param($type) unless ($self->{rowSwitch} == 1);

    my $objsRef;
    if ($root) {
		# get objects that match the root
		# do single object - or some set of objects
		$objsRef = $self->getRoots($typeST,$SEName,$root);
    } else {
	#print STDERR " no root specified \n";
    	my $search_params = { __order => 'id' };
	# get all of the given type.
#	print STDERR "st .. " . Dumper($typeST) . "\n";
#	print STDERR "search params..\n";
#	print STDERR Dumper($search_params). "\n";

		my @objs = $factory->findObjects($typeST, $search_params);
		$objsRef = \@objs;		
    }
# 	print STDERR "root objects found ...\n";
# 	print STDERR Dumper($objsRef);
# 	print STDERR "\n";

    # now, objsRef is a reference to an aaray containing the list of
    # top-level items that I want to work with

    # get a tree of objects

	my $tree = $self->getTreeFromRootList($objsRef,@$paths);
#     print STDERR "tree...\n";
#     print STDERR Dumper($tree);
#     print STDERR "\n";
    # convert that tree into an array,
	my $flatTree = $self->flattenTree($tree);
	return ($root, $flatTree);
}




=head2 getRoots 

    my $arrayRef = $self->getRoots($type,$element,$root);

    Get the root objects corresponding to a comma-separated list of
    objects from the CGI parameter. load the object either by Name or
    by Id.

=cut

sub getRoots {
    my $self = shift;
    my ($type,$element,$rootList) = @_;
    my $session = $self->Session();
    my $factory = $session->Factory();
    my @objs;
    my @roots = split(/,/,$rootList);
    my $obj;
    my @someObjs; # new
    foreach my $root (@roots) {
	undef $obj;
	if ($root =~ /^\d+$/) {
	    # load by id
	    $obj = $factory->loadObject($type,$root);
	    if ($obj) {
		push(@objs,$obj);
	    }
	}
	else {
	    #$obj = $factory->findObject($type,Name=>['ilike',$root]);   # was just Name=>$root.
	    @someObjs = $factory->findObjects($type, $element => ['ilike',$root]);   # was just Name=>$root.
	    if (scalar(@someObjs)) {
			push(@objs,@someObjs);
	    }
	}    
	#if ($obj) {
	#    push(@objs,$obj);
	#}
    }
    return \@objs;
}

=head2 getTreeFromRootList

    my $tree = $self->getTreeFromRootList($objsRef,@$paths);

    Given  a list of root objects and a list of object types, populate
    the tree. The result is a reference to a hash of hashes that
    contains the values in the tree.

    Thus, if the path is Gene:ProbeGene:Probe:ImageProbe, the
    resulting hash will be keyed with the names and ids of all of the genes
    passed in as roots - @$objs.  For each gene, the hash will contain
    an entry for each Probe. The entry for each probe will be a hash 
    keyed by the name and id of the probe, with the actual probe
    object as a  value.

    For all of these hashes, the key will be a hybrid string resulting
    from the concatentation of the object name, two underscores "__"
    and the object id.  These underscores are necessary to allow for
    sorted by atributed_ids: without the id in the key, we would only
    be able to sort by name. However, for some STs  that have values
    with inherent order (such as EmbryoStage: 1-Cell, 2-Cell, 4-Cell,
    etc), this approach is not acceptable. So, we sort by attribute id
    instead, and strip these keys off later.

    Note that mapping classes are not included in the result, as they
    are only used to find the next level of descendant in the
    tree. Furthermore, we stop before we get to the last entry -
    (ImageProbe), as the combination of the entries at the second to
    last level (Probe) and the name of the last level (ImageProbe) is
    sufficient to get images for a given leaf object. To see why this
    is the case, note that the leaves will be Probe instances. So, to
    find the Images for a probe, we can look for images where
    ImageProbeList.Probe = our probe instance.

=cut

sub getTreeFromRootList {
    my $self =shift;
    my ($objs,@paths) = @_;

    my ($STName,$SEName) = split (/\./, shift @paths);
    my %tree;
    foreach my $obj (@$objs) {
		my $name    = $obj->$SEName();
		my $id      = $obj->id();
		my $key     = $name . "__" . $id;
		my $subtree = $self->getTree($obj,@paths);
		$tree{$key} = $subtree;
    }
    return \%tree;
}


=head2 getTree

    my $tree = $self->getTree($obj, $path)
    The workhorse that does the job of recursively building the tree
    starting from a given object and walking down the types given in path.
    for a given object.

=cut

sub getTree {
    my $self= shift;
    # note that we pass the type path in as an array, not a ref. to an
    # array. This guarantees that the array will be copied, so we
    # don't need to do an explicit copy with each recursion

    my ($obj,@paths) = @_;

    # now, $obj is a gene, $paths is
    # [ProbeGene,Probe]
    # or, an array of path steps from one object to the next.

    #termination condition - stop when we've hit the last class in the list

    return undef if (scalar(@paths) < 1);

	my %tree;

    # strategy.
    # Some objects in the path are mapping objects, which means they're simply a fancy
    # edge in our graph.  Other objects have field designations, which means they are nodes.
    # Getting to a node means we expand it and recurse over the children.
    # Getting to a map, we expand over the mapping objects, then recurse over each mapping object's child.
    # Getting a mapping object means that we shift the paths array an extra time to get to the child objects.
	my ($STName1,$SEName) = split (/\./, shift @paths);
#    print STDERR "getTree STName1,SEName: '$STName1','$SEName'\n";

	# Only shift out the next thing if the first thing had no field (i.e. was a map)
	my $STName2;
	($STName2,$SEName) = split (/\./, shift (@paths)) unless $SEName;
#    print STDERR "getTree STName2,SEName: '$STName2','$SEName'\n";

	my $accessor = "${STName1}List";
    my @objects = $obj->$accessor;
	foreach my $child (@objects) { # for each object
		# If the first path item was a map, then we have a list of map objects
		$child = $child->$STName2 if $STName2;
#     print STDERR "child...\n";
#     print STDERR Dumper($child);
#     print STDERR "\n";

		# recurse.
		$tree{$child->$SEName() . "__" . $child->id()} = $self->getTree($child,@paths);   
	}
    
    return \%tree;
}


=head2 flattenTree

    my $arrayRef = $self->flattenTree($tree);

    given a tree from getTreeFromRootList, this will turn flatten it
    into an array of values. This array will contain one entry for
    each of the leaves in the tree. These entries will consist of the
    complete path from a root object to a leaf. For all items in the
    list except for the leaf, the name of the object is given. For the
    leaf, the object itself is given
    
    This data is, of course, very redundant, but it is useful for
    populating table columns and headers.

=cut

sub flattenTree {
    my $self=shift;
    my $tree = shift;
    my @rows;

    #termination - must return an array containing one element,
    # which is an array of one element - the item in question
    # containing the last item
   if (ref($tree) ne 'HASH') {
       return undef;
   }

    #recursion
    foreach my $key (keys %$tree) {
		my $val = $tree->{$key};
		if (defined $val) {
			# recurse - flatten the values
			my $valRows = $self->flattenTree($val);
			
			# for each val in valrows, 
			# add key to the front
			foreach my $valRow (@$valRows) {
				unshift @$valRow,$key;
				push @rows,$valRow;
			}
		} else {
			my  @valRow;
			$valRow[0] = $key;
			push (@rows,\@valRow);
		}
    }
    # sort the rows by id of first item.
    my @sortedRows = sort sortByIdKey @rows;

    # strip the ids off of the items.
    for (my $i = 0; $i < scalar(@sortedRows); $i++ ) {
		my $ent = $sortedRows[$i];
		for (my $j = 0; $j < scalar(@$ent); $j++) {
			my $val = $ent->[$j];
			#if ($val =~ m/([^_]*)__\d+/) {
			if ($val =~ m/(.*)__\d+/) {
			$ent->[$j]=$1;
			}
		}
    }

    return \@sortedRows;
}

=head3 sortByIDKey
    sortByIDKey ($a,$b) 
    
    sorts the items by order of the ids contained in their
    "$name__$id" first element.


=cut

sub sortByIdKey {
    $a->[0]=~ /[^_]*__(\d+)/;
    my $aID = $1;
    $b->[0]=~ /[^_]*__(\d+)/;
    my $bID = $1;
    return $aID <=> $bID;
}

    


=head2 populateCells

    my ($cells,$activeRows,$activeCols) = $self->populateCells($types);

    Get the objects to fill the matrix. Return a nested hash:
    first-level keyed by row id, second by column, with value being
    the list of images in the cell defined by that row,column pair.

    $activeRows and $activeColumns are hashes indicating which
    rows/columns have data. Only those rows/columns with data will be
    drawn.

=cut

sub populateCells {
    my $self    = shift;
    my $session = $self->Session();
    my $factory = $session->Factory();

    my ($types)    = @_;
    my $rowName    = $self->{rows};
    my $colName    = $self->{columns};
    my $rowEntries = $self->{rowEntries};
    my $colEntries = $self->{colEntries};
    
    # get rows by accessor 'ImageProbeList.Probe
    # to do this, get type entry for row,
    # get last entry - that gets us image probe.

    my $rowTypes = $types->{$rowName};
    my $colTypes = $types->{$colName};
#    print STDERR "  *** ROW TYPES \n";
#    print STDERR  Dumper($rowTypes) . "\n";
#    print STDERR "  *** COLUMN TYPES \n";
#    print STDERR  Dumper($colTypes) . "\n";


    my $cells;
    my %activeRows;
    my %activeColumns;
    my $hasData =0;

    my $start;
    my $total;
	foreach my $row (@$rowEntries) {
		# this is the of objects that define the row. let's get the
		# last item
		my $rowLeaf = $row->[scalar(@$row)-1];
#		print STDERR "row:\n".Dumper ($row);
	
		#thus, for example $rowLeaf is a probe
		#my $rName = $rowLeaf->Name;
		my $rName = $rowLeaf;
	
		# hard-code some stuff in.
		my %findHash = %{$self->{filters}};
		$findHash{'__distinct'} = 'id';
	
		# build up the query hash with values for all of the types  in
		# the row  that have mapping for images.
		$self->getImageAccessors(\%findHash,$rowTypes,$row);

#		print STDERR "findHash:\n".Dumper (\%findHash);
	
		# create a key that will uniquely identify this row.
		my $rowKey  =  $self->getCellKey($row);
	#	print STDERR "populate cells: column entries... ";
		#print STDERR Dumper($colEntries) ." \n";
		foreach my $col (@$colEntries) {
		 #   print STDERR "looking for data for column $col\n";
			
			# also look for those things that have been most recent.
			if (ref($col) eq 'ARRAY') { 
				# if columns specified, use them to get images.
				$self->getImageAccessors(\%findHash,$colTypes,$col);
			}
#print STDERR "findHash for finding images:\n".Dumper (\%findHash);
			my @images =
				$factory->findObjects('OME::Image',\%findHash);
			my $imagesRef = \@images;
# print STDERR "images:\n".Dumper (\@images);
			
		
			if ($self->{Category} && $self->{CategoryGroup}) {
				$imagesRef = $self->filterByCategory($imagesRef);
			}
	
			# if I find any, store them in double-hashed - keyed off
			# of row name and column name.
			# indicate when a row and column is active.
			if (@images && scalar(@$imagesRef) > 0) {
				# key for referencing the column starts out as null
				my  $colKey = $NO_COLS;
				if (ref($col) eq 'ARRAY')  {
					# set it to the appropriate key if the columns exist.
					$colKey  = $self->getCellKey($col);
				}
				$cells->{$rowKey}->{$colKey}  = $imagesRef;
				$activeRows{$rowKey}=1;
		
				$activeColumns{$colKey} = 1;
				$hasData =1;
			}
		}
	}
    return (undef,undef,undef) if ($hasData == 0);

    my $aRows = $self->getActiveList($rowEntries,\%activeRows);
    my $aColumns = $self->getActiveList($colEntries,\%activeColumns);
    return ($cells,$aRows,$aColumns);
}

=head2 getCellKey

    my $key = $self->getCellKey($entry);

    The key for a cell is the concatenation of all of the names 
    that specify that cell.

    $entry is a reference to an array  containing the items in the
    row/column

=cut

sub getCellKey {
    my $self=shift;
    my $entry = shift;
    my $key;
    for (my $i =  0;  $i < scalar(@$entry); $i++) {
	$key .= $entry->[$i];
    }
    return $key;
}

=head2 getImageAccessors
    $self->getImageAcessors($findHash,$types,$item);

   populate the find hash for a given set of criteria.
    $findHash is the hash that will eventually be provided to 
    a factory call to find images.

    $types is a sequence of types for a row/column
       (e.g.,  WormLocation,WormLocationStrain,Strain)
    $item  is the entries in a given row/Column 
       (e.g., ('Terminal Bulb','fem-1')

     This will go through the entries in the items list and the
	entries in the types list, building up a set of criteria
	based on the contents of self-{ImageMaps.}

	In the example given above, if WormLocation maps to
	ImageWormLocation, the entry
	'ImageWormLocationList.WormLocation.Name'=>'Terminal Bulb'
	will be added to the hash.
	
=cut

sub getImageAccessors {
	my $self =shift;
	my ($findHash,$types,$item) =@_;
# print STDERR "getImageAccessors types:\n".Dumper ($types);
# print STDERR "getImageAccessors item:\n".Dumper ($item);

	# for every item, look at types in the list.
	# The types list will have as many object.field types as there are values in the item list.
	# There may or may not be mapping types interspersed in the types list.

	my ($itemType,$j) = (0,0);
	for (my $i =0; $i < scalar(@$item); $i++) {
		my $value = $item->[$i];
		# Use $itemType as an index into types that contains the object and field for the current item
		# find the type for this item in the types list - it will be the next type with a field
		for ($j = $itemType; $j < scalar(@$types); $j++, $itemType++) {
			last if $types->[$j] =~ /\./;
		}
		
		# $key is what we prepend things to from the types list
		# The key has to begin with the type and field that corresponds to the current item
		my $key = $types->[$itemType];
		# split the object and the field from the types
		my ($type,$field) = split (/\./,$key);
#print STDERR "$type.$field = $value; key is $key\n";
		# Now we have to go the rest of the way in the types list, adding maps and types until we get
		# to the end of the type list.
		for ($j = $itemType+1; $j < scalar(@$types); $j++) {
			my ($pathType,$pathField) = split (/\./,$types->[$j]);
			if ($pathField) { # Not a map.
				$key = "$pathType.$key";
			} else { # Its a map
				$key = "${pathType}List.$key";
			}
		}
		# we're done with the itemType for this item, so increment it for the next item.
		$itemType++;
#print STDERR "$type.$field = $value; key is now $key\n";
		
		# get the mapping type out   at end
		my $imageMap = $self->{ImageMaps}->{$types->[$j-1]};
		if ($imageMap)  {
			# imageMap is now a class name like ImageWormLocation
			# $type is WormLocation
			# to make the appropriate factory criteria
			# we must realize that the imageMap will be a list 
			# associated with the image
			my $key  = "${imageMap}List.". $key;
			# value we want to associate with it comes from the row/col
			$findHash->{$key}  = $value;
		}
	}
	
	
}
	    

=head2 filterByCategory
    my $imagesRef= $self->filterByCategory($imagesRef);

    filter a list of images, returning only those that have group and 
    category matching $self->{CategoryGroup} and $self->{Category}

=cut

sub filterByCategory {
    my ($self,$images) = @_;
    my $cg = $self->{CategoryGroup};
    my $cat = $self->{Category};
    my @filtered;

    foreach my $image (@$images) {
	my $classification = 
	    OME::Tasks::CategoryManager->getImageClassification($image,$cg);
	if ($classification) {
	    # potential match
	    if (ref($classification) eq 'ARRAY') {
		foreach my $class (@$classification) {
		    if ($class->Category->Name eq $cat->Name) {
			push (@filtered,$image);
			last;
		    }
		}
	    }
	    else {
		if ($classification->Category->Name eq $cat->Name) {
			push (@filtered,$image);
		}
	    }
	}
    }
    return \@filtered;
}

=head2 getActiveList
    

    my $arrayRef = $self->getActiveList($items,\%active)

    $items is the list of all items (either for all rows or all
    columns. We wish to filter this list to find only those things
    that are active - ie., those cells that have data.

    However, the cells are keyed off of the names of the last item in
    the entry list - that which is "closest" to the data. So, we look
    at the name of the last item in each entry in the items list. If
    that name is found in the active hash, we save it. These lets us
    keep only those items from $items that are active, and to keep
    them in the order in which they were found. The _entire_ active
    item is returned in the resulting array.

=cut

sub getActiveList {
    my $self=shift;
    my ($items,$active) = @_;
    my @results;
    foreach my $entry (@$items) {
		my $name;
		if ($entry eq $NO_COLS) {
			# if we see the $NO_COLS marker, just use that name 
			#  to check the hash.
			$name = $entry;
		} else {
			$name = $self->getCellKey($entry);
		}
		push (@results,$entry) if ($active->{$name});
    }
    return \@results;
}
 

=head2 populateColumnHeaders
    my $colHeaders =
       $self->populateColumnHeaders($container,$activeCols,
                $rowEntrySize,$colPath);

    Put headers in the columns of the table. $rowSize is the number of
    columns that will be needed for header information for row
    entries. $colPath is the path of types to the columns.

=cut

sub populateColumnHeaders {
    my $self=shift;
    my ($container,$columns,$rowSize,$colPath) = @_;
    
    
    # create empty headers as need be.
    my  $emptyHeaders = $self->populateEmptyColumnHeaders($rowSize);
    my @headers;
    my $rowCount = 0;
    my $firstCol = $columns->[0];

    # if first column is not an array, we have no columns.
    if (ref($firstCol) ne 'ARRAY') {
	# in this caes, the $NO_COLS value has been set, so we don't
	# need any column headers.
	return undef;
    }
    $rowCount = scalar(@$firstCol); # of rows in column headers
    # is one less than the number of element in the first column.
    # this is also the # of field in the column..


    # colPath is the returned value for types let's start by stripping out
    # the map types.
    my $colTypes = $self->filterOutMaps($colPath);


    my @prevColumns;
    # for each row in columns
    for (my $i =0; $i < $rowCount; $i++)  {
	my %header;
	
	# get appropiate # of empty heders.
	$header{emptyColumnHeaders} = $emptyHeaders;
	my @columns;

	# clear out any previous columns for this row
	@prevColumns = ();

	# for each column in that row.
	for (my $j = 0; $j < scalar(@$columns); $j++) {

#  print STDERR "populateColumnHeaders : columns->[$j]->[$i] = $columns->[$j]->[$i]:\n";
	    my $same =1;
	    # look @ all previous entries in this column to see if
	    # they match  whatever was in the most recent column
	    for (my $k = 0; $k <= $i; $k++) {
		if (!$prevColumns[$k] || 
		    $columns->[$j]->[$k] ne $prevColumns[$k]) { 
		    # if any difference, bail out
		    $same  = 0;
		    last;
		}
	    }


	    # if it's not the same,
	    if (!$same) {
		# get the val.
		my  $val = $columns->[$j]->[$i];
#  print STDERR "NOT SAME populateColumnHeaders : columns->[$j]->[$i] = $columns->[$j]->[$i]:\n";

		my %column;
		# find out how many times the column is repeating.
		my $colSpan =
		    $self->getRepeatCount($columns,$j,$i);
		$column{columnNameSpan} = $colSpan;
		
		# get the link content for this value
		$column{columnNameEntry} =  
		    $self->getTextFor($container,$val,$colTypes->[$i]);
	    

		push(@columns,\%column);
		# update the previous entry.
		$prevColumns[$i] = $val;
	    }
	}
	# do each of the headers.

	$header{columnNameEntries} = \@columns;
	push(@headers,\%header);
    }
    return \@headers;
}

=head2 populateEmptycolumnHeaders
    
    my $emptyColumns = $self->populateEmptyColumnHeaders($size);

   create  the requisite number of empty column headings.

=cut 


sub populateEmptyColumnHeaders {
    my $self=shift;
    my $size = shift;
    
    my @headers;
    for (my $i=0; $i < $size; $i++) {
	my %header;
	$header{emptyColumnHeader}="";
	push(@headers,\%header);
    }
    return \@headers;
}


=head2 getHeaderSize

    my $headerSize = $self->getHeaderSize($rowEntries)

    return the number of items that must be printed in the header for
    each row/column

=cut

sub getHeaderSize {
    my $self= shift;
    my $rowEntries = shift;
    my $row = $rowEntries->[0];
    my $size =scalar(@$row);
    return $size;
}

=head2 populateBody

    my $body =	 $self->populateBody($container,$cells,$activeRows,
				$activeCols,$rowPath);
    Populate the body, one row at a time.

    Simimlar to populateColumnHeaders, except here we call
    populateRow, which eventually renders all of the images.
    
=cut

my $renderArrayTime = 0;
my $getTextForTime =0;

sub populateBody {
    my $self= shift;

    my ($container,$cells,$activeRows,$activeCols,$rowPath) = @_;

    # rowPath is the returned value for types, which will have the
    # form ST, map, ST, map, etc. let's start by stripping out
    # every other item.
    my $rowTypes = $self->filterOutMaps($rowPath);

    my @cellRows;

    my  @prev; # what's in the previously printed row.
    
    for (my $rowIndex= 0 ; $rowIndex <scalar(@$activeRows); $rowIndex++) {
		my $row = $activeRows->[$rowIndex];
		my %rowContents;
		my @entries;
		
		my  $same=1; # are we in same row as previous?
	
		# $i is the index - which field in the row.
		for (my $i = 0; $i < scalar(@$row); $i++) {
			my $val = $row->[$i];
			if ( ($val && (!$prev[$i] || ($val ne $prev[$i])))
			 || $same == 0) {
				my %entry;
				my $rowSpan = $self->getRepeatCount($activeRows,$rowIndex,$i);
				my $start=[gettimeofday()];
				$entry{rowNameEntry} = $self->getTextFor($container,
									 $val,
									 $rowTypes->[$i]);
				$getTextForTime += tv_interval($start);
				$entry{rowNameSpan} = $rowSpan;
				push(@entries,\%entry);
		
				$prev[$i] = $val;
				$same = 0;
			} else {
				$same = 1;
			}
		}
		$rowContents{rowName} = \@entries;
		$rowContents{rowCells} = 
			$self->populateRow($container,$cells,$row,$activeCols);
		push (@cellRows,\%rowContents);
    }
    return \@cellRows;

}

=head2 filterOutMaps

    my $filteredPath = $self->filterOutMaps($path);

    Given a path consisting of the names of types, alternating between
    object types and map types, return an array containing only the
    object types.

=cut

sub filterOutMaps {
    my ($self,$path)  = @_;
	my @filtered = grep (/\./,@$path);
    return \@filtered;
}
   
=head2 
    my $cnt =$self->getRepeatCount($entries,$start,$field)

    How many times do we see repeats of the values in
    $entries->[$start], where fields 0..$field are all equal to 
    those in $entries->[$start]? Used to determine when a column/row
    header should span multiple columns/rows.
    

=cut

sub getRepeatCount {
    my ($self,$entries,$start,$field) = @_;

    my $template = $entries->[$start];
    my $cnt = 1;
    for (my $j = $start+1; $j < scalar(@$entries); $j++) {
	my $rec = $entries->[$j];
	for (my $k = 0; $k <= $field; $k++) {
	    return $cnt if ($rec->[$k] ne $template->[$k]); # ok,
				# we're done - unequal filed
	}
	$cnt++;
    }
    return $cnt;
}
    
    
=head2 getTextFor

    my $text = $self->getTextFor($container,$name,$type);
    given a name of an item and the type of an item,
    find the string to put in a cell.
    put the name of the obect and the links to an ExternalLink objects
    that are ssociated. These links will display the "Description"
    field for the external links. 

    if there are no ExternalLinks, display an object detail URL.


=cut

sub getTextFor {
	my ($self,$container,$name,$type)  = @_;
	my $session = $self->Session;
	my $factory = $session->Factory;
	my $q = $container->CGI;
	
	my $text = $name; #default
	my ($STName,$SEName) = split (/\./, $type);
	
	
	my $typeName = "@".$STName;
	
	# find the object
	my $obj = $factory->findObject($typeName,$SEName=>$name);
	if ($obj) {
		my $extLink = $self->getExternalLinkText($q,$STName,$obj);
		if ($extLink) {
			$text .= "<BR>".$extLink;
		}
	}
	return $text;
}

=head2 populateRow

    my $rowCells = $self->populateRow($container,$cells,$row,$activeCols);
    

    put sets of images from cells into the output table.

=cut

sub populateRow {
    my $self=shift;
    my ($container,$cells,$row,$activeCols) = @_;
    my $cg= $self->{CategoryGroup};
	

    #my $rowLeaf = $row->[scalar(@$row)-1];
    my $rowKey =  $self->getCellKey($row);
    #my $rowName = $rowLeaf->Name;
    my @cells;
    foreach my $col (@$activeCols) {
	my $colName;
	if ($col eq $NO_COLS) {
	    # if the column name is $NO_COLS, use that name to access 
	    # images from the hahs.
	    $colName=$col;
	}
	else  {
	    # $col s the entire path array for each column
	    # find the last entry in it.
	#    my $colLeaf = $col->[scalar(@$col)-1];
	#    $colName = $colLeaf->Name;
	    $colName = $self->getCellKey($col);
	}
	# get cells
	my $images = $cells->{$rowKey}->{$colName}; # was rowName as first key
	#render them.
	my $cell = $self->getRendering($container,$images,$cg);

	push(@cells,$cell);
    }
    return \@cells;
}


=head2 getRendering

    my $rendering = $self->getRendering($container,$images,$cg);

    Render the images according to the category group

=cut

sub getRendering {
    my ($self,$container,$images,$cg) = @_;
    my %cell;

    if ($images) {
	# sort them by category group first.
	my $renderer=$container->Renderer();
	my $renderHash = { type=>'OME::Image',
				     Rows => $self->{rows},
				     Columns=> $self->{columns},
			   Template=>$self->{Template},
	                   Page=>$self->{returnPage}};
	my $sortedImages = $images;
	if ($cg) {
	    $sortedImages = $self->sortImagesByCG($images,$cg);
	    $renderHash->{CategoryGroup} = $cg if ($cg);
	}

	my $start =[gettimeofday()];
	my $rendering =
	    $renderer->renderArray($sortedImages,'color_code_ref_mass_by_cg',$renderHash);
			
	$renderArrayTime += tv_interval($start);
	$cell{cell} = $rendering;
    }
    return \%cell;
}

=head2

    my $sortedImageArrayRef = $self->sortImagesByCG($images,$cg);
   

    Sort the images by cateogory  in a given group.

=cut

sub sortImagesByCG {
    my ($self,$images,$cg) = @_;
    
    my @cgArray;
    foreach my $image (@$images) {
        # for each image, get the cg.
	my $classification = 
	    OME::Tasks::CategoryManager->getImageClassification($image,$cg);
	my $catName="";
	if ($classification) {
	    $catName = $classification->Category->Name;
	}
       # populate a new array. each element in this array is a pair
       # containing [$catName, $image];

	my @imgDetail = ($catName,$image);
	push(@cgArray,\@imgDetail);
    }
    
    # sort by category group name
    my @sortedImages = sort { $a->[0] cmp $b->[0] } @cgArray;

    # pull images out of sorted list.
    my @newImages = map {$_->[1]} @sortedImages;

    return \@newImages;
}


1;
