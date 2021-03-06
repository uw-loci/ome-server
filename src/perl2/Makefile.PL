#!/usr/bin/perl
use ExtUtils::MakeMaker;
use Cwd qw(cwd abs_path);
use English;

	my $pwd = abs_path(cwd()) || die "Can't figure out your cwd!";

	if  ($ARGV[0] eq 'uninstall') {
		uninstall();
	} else {
		print "You can remove all previous versions of OME with the following command:\n";
		print "perl Makefile.PL uninstall\n";
		print "--------------------------\n";
		
		# the sym-link to DistributedAnalysisEngineCGI.pl has got to go for the moment
		print "Removing sym-linked DistributedAnalysisEngineCGI.pl and not caring if we succeed.\n";
		unlink "DistributedAnalysisEngineCGI.pl";
		
		# the OME/Matlab directory is a problem child because it's C code in a directory of
		# perl code. We have to go inside and do a make clean. Otherwise all the .o files 
		# left over from a previous installation cause this installation to fail
		my $iwd = cwd();
		print "Performing `make clean` in directory $iwd/OME/Matlab\n";
		chdir ($iwd.'/OME/Matlab');
		my $iEUID = $EUID;
		$EUID = 0;
		system('make clean');
		$EUID = $iEUID; 
		chdir ($iwd);
		
		WriteMakefile(
			NAME         => 'OME',
			VERSION_FROM => 'OME.pm', # finds $VERSION
			AUTHOR       => 'Ilya Goldberg, Doug Creager, Brian Hughes, Josiah Johnston (igg@nih,gov, dcreager@alum.mit.edu, bshughes@mit.edu, siah@nih.gov)',
			ABSTRACT     => 'The Open Microscopy Environment',
			DIR          => ['OME/Image/Pix','OME/ImportExport/Repacker/'],
            EXE_FILES    => ['OME/Java/omejava'],
			INST_BIN     => File::Spec->catdir($pwd,'blib','bin'),
			INST_LIB     => File::Spec->catdir($pwd,'blib','lib'),
			INST_ARCHLIB => File::Spec->catdir($pwd,'blib','arch'),
			INST_SCRIPT  => File::Spec->catdir($pwd,'blib','script'),
			INST_MAN1DIR => File::Spec->catdir($pwd,'blib','man1'),
			INST_MAN3DIR => File::Spec->catdir($pwd,'blib','man3'),
		
		#    realclean    => {FILES => 'OME/Image/blib'}  
		);
	}

#
# This is harsh and probably dangerous, it also misses the 'man' directories,
# Other than the .packlist, this should things sqeaky clean, though.
sub uninstall {
use File::Spec;
use File::Find;
use Config;
my %searchdirs;

	foreach (@INC) {
		if ( (abs_path($_) ne $pwd) and ($_ ne '.') ) {
			$searchdirs{$_} = 1;
		}
	}

	File::Find::find( sub {
		my @dirs = File::Spec->splitdir($File::Find::name);
	    if ($dirs[$#dirs] eq 'OME') {
	    	print "Deleting ",$File::Find::name,"...\n";
	    	system ('rm -rf '.$File::Find::name);
			$File::Find::prune = 1;
		}
	}, keys %searchdirs);

}

#
# This mechanism doesn't seem to get all the files...
sub uninstall2 {
use ExtUtils::Installed;
my ($inst) = ExtUtils::Installed->new();
my @files = $inst->files('OME');
my @directories = sort {$b cmp $a} $inst->directories('OME');

	foreach (@files) {
		print "Deleting $_";
		unlink ($_) || print " Error: $!";
		print "\n";
	}

	foreach (@directories) {
		print "Deleting $_";
		rmdir ($_) || print " Error: $!";
		print "\n";
	}

	$inst->validate('OME',1);
	$inst->packlist('OME')->write();
}
