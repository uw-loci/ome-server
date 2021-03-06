#!/usr/bin/perl -w
# Author:  Ilya G. Goldberg (igg@mit.edu)
# Copyright 1999-2001 Ilya G. Goldberg
# This file is part of OME.
# 
#     OME is free software; you can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published by
#     the Free Software Foundation; either version 2 of the License, or
#     (at your option) any later version.
# 
#     OME is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU General Public License for more details.
# 
#     You should have received a copy of the GNU General Public License
#     along with OME; if not, write to the Free Software
#     Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
# 
#

use OMEpl;
use strict;
use vars qw ($OME);

$OME = new OMEpl;

if ($OME->cgi->param('CreateView')) {
	CreateView();
} elsif ($OME->cgi->param('PreviewData')) {
	TablePreview(
		TmpltName=>$OME->cgi->param('DataTempl')
	);
} elsif ($OME->cgi->param('PreviewProject')) {
	TablePreview(
		TmpltName=>$OME->cgi->param('ProjTempl')
	);
} elsif ($OME->cgi->param('EditSQLdata')) {
	PrintSQLForm (TmpltName=>$OME->cgi->param('DataTempl'),TmpltType=>'Dataset');
} elsif ($OME->cgi->param('EditSQLproject')) {
	PrintSQLForm (TmpltName=>$OME->cgi->param('ProjTempl'),TmpltType=>'Project');
} elsif ($OME->cgi->param('EditSQLpreview')) {
	TablePreview (
		TmpltName=>$OME->cgi->param('TmpltName'),
		TmpltSQL=>$OME->cgi->param('TmpltSQL'),
		TmpltType=>$OME->cgi->param('TmpltType')
	);
} elsif ($OME->cgi->param('SaveTemplate')) {
	SaveTemplate (
		TmpltName=>$OME->cgi->param('TmpltName'),
		TmpltDescr=>$OME->cgi->param('TmpltDescr'),
		TmpltSQL=>$OME->cgi->param('TmpltSQL'),
		TmpltType=>$OME->cgi->param('TmpltType'),
		ForceSave=>$OME->cgi->param('ForceSave')
	);
} elsif ($OME->cgi->param('Error')) {
	$OME->Return_to_referer;
} else {
	PrintViewForm ();
}

$OME->Finish();
undef $OME;


sub PrintViewForm {
my $cgi = $OME->cgi;
my $DB = $OME->DBIhandle;
my ($row,@tableRows);
my (@prjTemplNames,@prjTemplDescs);
my (@datTemplNames,@datTemplDescs);
my $tmplNum=0;
my $projectName = $OME->GetProjectName();

	print $OME->CGIheader();
	print $cgi->start_html(-title=>'Create Database Views',-BGCOLOR=>'white');
	print "<CENTER>";
	print $cgi->h3("Create Database Views");
	print $cgi->startform;
	print "</CENTER>";
	print "<BR>";


	my $templates = $DB->selectall_arrayref ("SELECT name,description,type FROM view_templates");
	
	foreach (@$templates) {
		if ($_->[2] eq 'Project') {
			push (@prjTemplNames,$_->[0]);
			push (@prjTemplDescs,$_->[1]);
		} elsif ($_->[2] eq 'Dataset'){
			push (@datTemplNames,$_->[0]);
			push (@datTemplDescs,$_->[1]);
		}
	}



	if (defined $OME->GetProjectID) {
		print $cgi->checkbox(-name=>'doProjView',-value=>'on',-checked=>1,-label=>'Create view for selected project');
		print "<BLOCKQUOTE >";
	
		push (@tableRows,$cgi->th(['Name','Description']));
		
	
		my @projSelect = $cgi->radio_group(-name=>'ProjTempl',
									-values=>\@prjTemplNames,-default=>$prjTemplNames[0]);
		
		foreach (@prjTemplNames) {
			push (@tableRows,$cgi->td([$projSelect[$tmplNum],$prjTemplDescs[$tmplNum]]));
			$tmplNum++;
		}
	
	
		print $cgi->table({-border=>1,-cellspacing=>2,-cellpadding=>2},
			$cgi->Tr(\@tableRows)
			);
		print $cgi->submit(-name=>'PreviewProject',
					-label=>'Preview Table');
		print $cgi->submit(-name=>'EditSQLproject',
					-label=>'Preview/Modify SQL');
		print $cgi->submit(-name=>'CreateView',
					-label=>'Create View');
		print "Named: ".$cgi->textfield(-name=>'PViewName', -default=>$projectName, -size=>32);
		print "</BLOCKQUOTE >";
		print "<BR>";
	} else {
		print $cgi->h4('No project selected<BR>Select a project in order to edit project templates and create project views.');
	}

	@tableRows = ();
	print $cgi->checkbox(-name=>'doDataView',-value=>'on',-label=>'Create views for selected datasets');
	print "<BLOCKQUOTE >";
	push (@tableRows,$cgi->th(['Name','Description']));

	my @dataSelect = $cgi->radio_group(-name=>'DataTempl',
                                -values=>\@datTemplNames,-default=>$datTemplNames[0]);
	
	$tmplNum=0;
	foreach (@datTemplNames) {
		push (@tableRows,$cgi->td([$dataSelect[$tmplNum],$datTemplDescs[$tmplNum]]));
		$tmplNum++;
	}


	print $cgi->table({-border=>1,-cellspacing=>2,-cellpadding=>2},
		$cgi->Tr(\@tableRows)
		);
	print $cgi->submit(-name=>'PreviewData',
		        -label=>'Preview Table');
	print $cgi->submit(-name=>'EditSQLdata',
		        -label=>'Preview/Modify SQL');
	print $cgi->submit(-name=>'CreateView',
		        -label=>'Create Views');
	print "Named: ".$cgi->textfield(-name=>'DViewName',
							  -default=>'$(DatasetName)', -size=>32);
	print "</BLOCKQUOTE >";

	print $cgi->endform;
	print $cgi->end_html;

	
}


sub TablePreview {
my %params = @_;
my $cgi = $OME->cgi;
my $DB = $OME->DBIhandle;
my $tmpltName = $params{TmpltName};
my $template = $params{TmpltSQL};
my $datasetNum = $params{DatasetNum};
my $SQL;
my @tableRows;
my $error;

	print $OME->CGIheader(-target=>'_blank');
	print $cgi->start_html(-title=>"Preview of '$tmpltName'",-BGCOLOR=>'white');

	if (not defined $template) {
		$template = $DB->selectrow_array("SELECT template FROM view_templates WHERE name='$tmpltName'");
	}

	$datasetNum = 0 unless defined $datasetNum;
	my $datasetID = $OME->GetSelectedDatasetIDs->[$datasetNum];
	my $projectID = $OME->GetProjectID;


	print $OME->CGIheader (-type=>'text/html');
	print $cgi->start_html(-title=>$tmpltName,-BGCOLOR=>'white');

	if (not defined $projectID and $template =~ /\$\(ProjectID\)/ ) {
#		print $cgi->startform;
		print $cgi->h3('There is no project selected.<BR>');
#		print $cgi->submit(-name=>'Error',
#					-label=>'OK');
#		print $cgi->endform;
	} else {
		$SQL = MakeSQL ($template,$datasetID,$projectID);
	#	print $SQL;

		my $RaiseError = $DB->{RaiseError};
		$DB->{RaiseError} = 0;
		my $sth = $DB->prepare($SQL);
		$sth->execute() unless $DB->errstr;
		$error = $sth->errstr;
		if (not defined $error) {
			@tableRows = $cgi->th ($sth->{NAME});
			my $tuple;
			while ( $tuple = $sth->fetchrow_arrayref() ) {
				push (@tableRows,$cgi->td($tuple));
			}
		}
		$DB->{RaiseError} = $RaiseError;

	
		if (defined $error) {
	# The database will ignore further queries in this transaction block if we generated an error.
			$OME->Commit();
			print $error,"<BR>";
		} else {
	
			print "<CENTER>";
			print $cgi->table({-border=>1,-cellspacing=>1,-cellpadding=>1},
				$cgi->Tr(\@tableRows));
		
		
			print " </CENTER>";
		}
	}
	print $cgi->end_html;


}


sub PrintSQLForm {
my %params = @_;
my $cgi = $OME->cgi;
my $DB = $OME->DBIhandle;
my $tmpltName = $params{TmpltName};

my ($description,$template,$type) = ($params{TmpltDescr},$params{TmpltSQL},$params{TmpltType});

	($type,$description,$template) = 
		$DB->selectrow_array("SELECT type,description,template FROM view_templates WHERE name='$tmpltName'")
			unless (defined $description and $description and defined $template and $template and defined $type and $type);

	if (not exists $params{supressHeader} or not defined $params{supressHeader}) {
		print $OME->CGIheader();
		print $cgi->start_html(-title=>'Create Database Views',-BGCOLOR=>'white');
	}
	print "<CENTER>";
	print $cgi->h3("Modify View Template");
	print "</CENTER>";
	print "<BR>";
	if (not exists $params{supressStartform} or not defined $params{supressStartform}) {
		print $cgi->startform;
	}
	
	print "Name: ".$cgi->textfield(-name=>'TmpltName',
                              -default=>$tmpltName);
	print "&nbsp &nbsp Type: ".$type." view template";
	print $cgi->hidden(-name=>'TmpltType',
                              -default=>$type);
	print "<BR>";
	print "Description: ".$cgi->textfield(-name=>'TmpltDescr',
                              -default=>$description, -size=>80);
	print "<BR>";
	print "SQL Template: <BR>".$cgi->textarea(-name=>'TmpltSQL',
					-default=>$template,
					-rows=>20,
					-columns=>100);
	print "<BR>";
	print $cgi->submit(-name=>'EditSQLpreview',
		        -label=>'Preview Table');
	print $cgi->submit(-name=>'SaveTemplate',
		        -label=>'Save Template');
	print $cgi->submit(-name=>'CreateView',
		        -label=>'Create View');
	
	if ($type eq 'Project') {
		print "Named: ".$cgi->textfield(-name=>'PViewName',
								  -default=>$OME->GetProjectName(), -size=>32);
    } elsif ($type eq 'Dataset') {
		print "Named: ".$cgi->textfield(-name=>'DViewName',
								  -default=>'$(DatasetName)', -size=>32);
    }

	print $cgi->endform unless defined $params{supressEndForm};
	print $cgi->end_html unless defined $params{supressEndHTML};
}


sub MakeSQL {
my ($template,$datasetID,$projectID) = @_;
my $experimenterID = $OME->GetExperimenterID();

	$template =~ s/\$\(ProjectID\)/$projectID/g;
	$template =~ s/\$\(DatasetID\)/$datasetID/g;
	$template =~ s/\$\(ExperimenterID\)/$experimenterID/g;
	return $template;
}


sub SaveTemplate {
my %params = @_;
my ($tmpltName,$description,$template,$type,$forceSave);
my $cgi = $OME->cgi;
my $DB = $OME->DBIhandle;

	$tmpltName = $params{TmpltName};
	$forceSave = $params{ForceSave};

	print $OME->CGIheader();
	print $cgi->start_html(-title=>'Save Template',-BGCOLOR=>'white');
	print $cgi->startform;

	($type,$description) = 
		$DB->selectrow_array("SELECT type,description FROM view_templates WHERE name='$tmpltName'");
	if ( ((defined $type and $type) or (defined $description and $description)) and not $forceSave) {
		print $cgi->h4("$type template '$tmpltName' already exists:<BR>Description: '$description'<BR><BR>");
		($description,$template,$type) = ($params{TmpltDescr},$params{TmpltSQL},$params{TmpltType});
		print $cgi->hidden(-name=>'ForceSave',-default=>1);
		print $cgi->submit(-name=>'SaveTemplate',
					-label=>'Save Anyway');
	} elsif ($forceSave) {
		($description,$template,$type) = ($params{TmpltDescr},$params{TmpltSQL},$params{TmpltType});
		print STDERR "OMEcreateViews:<UPDATE view_templates set description='$description',template='$template' WHERE name='$tmpltName'>\n";
# We need to escape single quotes here with '\', because otherwise they's close the quote on the SQL string.
		$template =~ s/\'/\\\'/g;
		$DB->do("UPDATE view_templates set description='$description',template='$template',type='$type' WHERE name='$tmpltName'");
		print "<BR>Template '$tmpltName' updated.";
	} else {
		($description,$template,$type) = ($params{TmpltDescr},$params{TmpltSQL},$params{TmpltType});
# We need to escape single quotes here with '\', because otherwise they's close the quote on the SQL string.
		$template =~ s/\'/\\\'/g;
		$DB->do("INSERT INTO view_templates (name,type,description,template) ".
			"VALUES ('$tmpltName','$type','$description','$template')");
		print "<BR>Template '$tmpltName' added.";
	}
	$params{supressHeader} = 1;
	$params{supressStartform} = 1;
	PrintSQLForm (%params);
	
}

sub CreateView {
my $tmpltName;
my $cgi = $OME->cgi;
my $DB = $OME->DBIhandle;
my $datasets = $OME->GetSelectedDatasetObjects;
my $projectID = $OME->GetProjectID;
my $projectName = $OME->GetProjectName();
my ($projTemplate,$dataTemplate,$doProject,$doDatasets);
my ($tmpltSQL,$tmpltType);
my ($PviewName,$DviewName);

	$tmpltSQL  = $OME->cgi->param('TmpltSQL');
	$tmpltType = $OME->cgi->param('TmpltType');
	$PviewName = $OME->cgi->param('PViewName');
	$DviewName = $OME->cgi->param('DViewName');


	if (defined $tmpltSQL and $tmpltSQL and defined $tmpltType and $tmpltType eq 'Project') {
		$projTemplate = $tmpltSQL;
		$doProject=1;
	} elsif (defined $tmpltSQL and $tmpltSQL and defined $tmpltType and $tmpltType eq 'Dataset') {
		$dataTemplate = $tmpltSQL;
		$doDatasets=1;
	} elsif (defined $cgi->param('DataTempl') or defined $cgi->param('ProjTempl')) {
		if (defined $cgi->param('doProjView') and  $cgi->param('doProjView') eq 'on') {
			$tmpltName = $cgi->param('ProjTempl');
			if (defined $tmpltName and $tmpltName) {
				$projTemplate = $DB->selectrow_array("SELECT template FROM view_templates WHERE name='$tmpltName'");
				$doProject=1;
			}
		}
	
		if (defined $cgi->param('doDataView') and  $cgi->param('doDataView') eq 'on') {
			$tmpltName = $cgi->param('DataTempl');
			if (defined $tmpltName and $tmpltName) {
				$dataTemplate = $DB->selectrow_array("SELECT template FROM view_templates WHERE name='$tmpltName'");
				$doDatasets=1;
			}
			
		}
	}



# Creating views is not fully isolated in transactions, so we turn them off.
# Since the DB handle is destroyed if we die or if we exit normally calling $OME->Finish,
# we just leave them off.
	$DB->{AutoCommit} = 1;


	if ($doProject and defined $projectID and defined $PviewName and $PviewName) {
		my $SQL = MakeSQL ($projTemplate,undef,$projectID);
		$PviewName =~ s/\$\(ProjectName\)/$projectName/g;
		$OME->DropView($PviewName);
		CreateDBview ($PviewName,$SQL);
	} elsif ($doProject and not defined $projectID) {
		DoErrorForm ('There is no project selected.');
	} elsif ($doProject and (not defined $PviewName or not $PviewName)) {
		DoErrorForm ('View name was not set.');
	}

	my $numDatasetViews=0;
	if ($doDatasets and defined $DviewName and $DviewName) {
		foreach (@$datasets) {
			my $SQL = MakeSQL ($dataTemplate,$_->ID,$projectID);
			my $name = $_->Name;
			my $thisViewName = $DviewName;
			$thisViewName =~ s/\$\(DatasetName\)/$name/g;
			$OME->DropView($thisViewName);
			CreateDBview ($thisViewName,$SQL);
			$numDatasetViews++;
		}
	} elsif ($doDatasets) {
		DoErrorForm ('View name was not set.');
	}


	print $OME->CGIheader();
	print $cgi->start_html(-title=>'Error',-BGCOLOR=>'white');
	if ($doProject) {
		print $cgi->h3("Project view '$PviewName' created.");
	}
	
	if ($doDatasets) {
		print $cgi->h3("$numDatasetViews dataset views created.");
	}
	print $cgi->end_html;
	
		

}


sub CreateDBview {
my ($viewName,$viewSQL) = @_;
my $DB = $OME->DBIhandle;
my $cgi = $OME->cgi;

		print STDERR "Creating view named $viewName as '$viewSQL'\n";
		$DB->do(qq/CREATE VIEW "$viewName" AS $viewSQL/);
		print STDERR "Done creating view\n";
}




sub DoErrorForm {

	die shift;
}
