# OME/Analysis/Handlers/CLIHandler.pm

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
# Written by:    Josiah Johnston <siah@nih.gov>
#
#-------------------------------------------------------------------------------


package OME::Analysis::Handlers::CLIHandler;

use strict;
use OME;
our $VERSION = $OME::VERSION;

use IPC::Run;
use Log::Agent;

use OME::Analysis::Handlers::DefaultLoopHandler;
use OME::Tasks::PixelsManager;
use OME::Image::Server::File;
use XML::LibXML;
use base qw(OME::Analysis::Handlers::DefaultLoopHandler);

use fields qw(_outputHandle);

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;

    my $self = $class->SUPER::new(@_);

    bless $self,$class;
    return $self;
}


sub startDataset {
    my ($self,$dataset) = @_;
    $self->SUPER::startDataset($dataset);

	my $module                  = $self->getModule();
	my $executionInstructions    = $module->execution_instructions();
	my $parser                   = XML::LibXML->new();
	
	my $tree                     = $parser->parse_string( $executionInstructions );
	my $root                     = $tree->getDocumentElement();
	my $ExecutionInstructionsXML = $root;#->getElementsByTagName( 'ExecutionInstructions' )->[0];

	if( $ExecutionInstructionsXML->getAttribute( 'ExecutionPoint' ) eq 'startDataset' ) {
		my @formalInputs          = $module->inputs();
		my %inputs;
        foreach my $input (@formalInputs) {
            $inputs{$input->name()} = $self->getCurrentInputAttributes($input);
        }
		$self->_execute(\%inputs);
	}
}

sub startImage {
    my ($self,$image) = @_;
    $self->SUPER::startImage($image);

	my $module                  = $self->getModule();
	my $executionInstructions    = $module->execution_instructions();
	my $parser                   = XML::LibXML->new();
	
	my $tree                     = $parser->parse_string( $executionInstructions );
	my $root                     = $tree->getDocumentElement();
	my $ExecutionInstructionsXML = $root;#->getElementsByTagName( 'ExecutionInstructions' )->[0];

	if( $ExecutionInstructionsXML->getAttribute( 'ExecutionPoint' ) eq 'startImage' ) {
		my @formalInputs          = $module->inputs();
		my %inputs;
        foreach my $input (@formalInputs) {
            $inputs{$input->name()} = $self->getCurrentInputAttributes($input);
        }
		$self->_execute(\%inputs);
	}
}

sub startFeature {
    my ($self,$feature) = @_;
    $self->SUPER::startFeature($feature);

	my $module                  = $self->getModule();
	my $executionInstructions    = $module->execution_instructions();
	my $parser                   = XML::LibXML->new();
	
	my $tree                     = $parser->parse_string( $executionInstructions );
	my $root                     = $tree->getDocumentElement();
	my $ExecutionInstructionsXML = $root;#->getElementsByTagName( 'ExecutionInstructions' )->[0];

	if( $ExecutionInstructionsXML->getAttribute( 'ExecutionPoint' ) eq 'startFeature' ) {
		my @formalInputs          = $module->inputs();
		my %inputs;
        foreach my $input (@formalInputs) {
            $inputs{$input->name()} = $self->getCurrentInputAttributes($input);
        }
		$self->_execute(\%inputs);
	}
}


sub finishFeature {
    my ($self) = @_;
    $self->SUPER::finishFeature();

	my $module                  = $self->getModule();
	my $executionInstructions    = $module->execution_instructions();
	my $parser                   = XML::LibXML->new();
	
	my $tree                     = $parser->parse_string( $executionInstructions );
	my $root                     = $tree->getDocumentElement();
	my $ExecutionInstructionsXML = $root;#->getElementsByTagName( 'ExecutionInstructions' )->[0];

	if( $ExecutionInstructionsXML->getAttribute( 'ExecutionPoint' ) eq 'finishFeature' ) {
		my @formalInputs          = $module->inputs();
		my %inputs;
        foreach my $input (@formalInputs) {
            $inputs{$input->name()} = $self->getCurrentInputAttributes($input);
        }
		$self->_execute(\%inputs);
	}
}

sub finishImage {
    my ($self) = @_;
    $self->SUPER::finishImage();

	my $module                  = $self->getModule();
	my $executionInstructions    = $module->execution_instructions();
	my $parser                   = XML::LibXML->new();
	
	my $tree                     = $parser->parse_string( $executionInstructions );
	my $root                     = $tree->getDocumentElement();
	my $ExecutionInstructionsXML = $root;#->getElementsByTagName( 'ExecutionInstructions' )->[0];

	if( $ExecutionInstructionsXML->getAttribute( 'ExecutionPoint' ) eq 'finishImage' ) {
		my @formalInputs          = $module->inputs();
		my %inputs;
        foreach my $input (@formalInputs) {
            $inputs{$input->name()} = $self->getCurrentInputAttributes($input);
        }
		$self->_execute(\%inputs);
	}
}

sub finishDataset {
    my ($self) = @_;
    $self->SUPER::finishDataset();

	my $module                  = $self->getModule();
	my $executionInstructions    = $module->execution_instructions();
	my $parser                   = XML::LibXML->new();
	
	my $tree                     = $parser->parse_string( $executionInstructions );
	my $root                     = $tree->getDocumentElement();
	my $ExecutionInstructionsXML = $root;#->getElementsByTagName( 'ExecutionInstructions' )->[0];

	if( $ExecutionInstructionsXML->getAttribute( 'ExecutionPoint' ) eq 'finishDataset' ) {
		my @formalInputs          = $module->inputs();
		my %inputs;
        foreach my $input (@formalInputs) {
            $inputs{$input->name()} = $self->getCurrentInputAttributes($input);
        }
		$self->_execute(\%inputs);
	}
}

sub _execute {
	my $self   = shift;
	my $i      = shift;
	my %inputs = %{ $i };

    my $image  = $self->getCurrentImage();

	my $module                = $self->getModule();
	my %outputs;
	my (%tmpFileFullPathHash);
	my $executionInstructions = $module->execution_instructions();
	my $debug                 = 0;
	my $session               = $self->Session();
	my $imagePix;
	my $CLIns = 'http://www.openmicroscopy.org/XMLschemas/CLI/RC1/CLI.xsd';
my $Pixels;
eval{ $Pixels = $self->getCurrentInputAttributes("Pixels")->[0]; };
my %dims = ( 'x'   => $Pixels->SizeX(),
			 'y'   => $Pixels->SizeY(),
			 'z'   => $Pixels->SizeZ(),
			 'w'   => $Pixels->SizeC(),
			 't'   => $Pixels->SizeT()
			 )
	if defined $Pixels;
	
	my $parser = XML::LibXML->new();
	my $tree = $parser->parse_string( $executionInstructions );
	my $root = $tree->getDocumentElement();
	
	my @elements;
	
	#####################################################################
	#
	# set up Plane Generation
	#
	# Notes:
	# 	the import process normalized planeID's - it gives every plane a unique ID and updates all references
	# 	autoIterators is hash reference. hash is keyed by planeID. values are references to hashes keyed by theZ, theW, & theT. these values are references to scalars.
	# 		The reason for this is each plane needs a set of plane indexes {theZ, theW, theT}, but sometimes a component of these will overlap.
	# 		For example, the cross correlation module needs two planes synced on theZ and theT with differing constant wavenumbers.
	# 		Since theZ theW and theT are references, it is a simple matter to sync any of these.
	#
	my $planeIndexes;
	my @planes = $root->getElementsByTagNameNS( $CLIns, "XYPlane" );
	if(scalar(@planes) > 0 ) {
		my $imagePix = $image->GetPix($Pixels)
			or die "Could not load image->Pix, image_ID = ".$image->id();
	}
	# planeIndexTypes is hard coded now because we only deal w/ XY planes. 
	my @planeIndexTypes   = ( 'theZ', 'theT', 'theW' );
	
		#####################################################################
		# First run through planes to generate plane indexes
		print STDERR "\n" if $debug eq 2;
		print STDERR "----------------------------------------------\n" if $debug eq 2;
		print STDERR "First plane run - generating indexes\n" if $debug eq 2;
		print STDERR "----------------------------------------------\n" if $debug eq 2;
		foreach my $plane(@planes) {
			my $planeID   = $plane->getAttribute( "XYPlaneID" );
			my %indexSize = ( theZ => $dims{'z'}, theT => $dims{'t'}, theW => $dims{'w'}, theX => $dims{'x'}, theY => $dims{'y'} );
			print STDERR "Processing plane ".$planeID."\n" if $debug eq 2;
			
			#################################################################
			#	Process indexes with non referential methods.
			foreach my $index (@planeIndexTypes) {
				my $indexXML    = $plane->getElementsByTagNameNS( $CLIns, $index )->[0];
				print STDERR "\tProcessing index: ".$index."\n" if $debug eq 2;
				#############################################################
				# AutoIterate
				if ( $indexXML->getElementsByTagNameNS( $CLIns, 'AutoIterate' ) ) {
					print STDERR "\t\tUses method: AutoIterate\n" if $debug eq 2;
					$planeIndexes->{ $planeID }->{$index} = 
						newScalarRef( 0 );
					$planeIndexes->{ $planeID }->{IterateStart}->{$index} = 
						0;
					$planeIndexes->{ $planeID }->{IterateEnd}->{$index} = 
						$indexSize{ $index }-1;
					$planeIndexes->{ $planeID }->{Output}->{$index} = 
						$indexXML->getElementsByTagNameNS( $CLIns, 'AutoIterate')->[0];
				#############################################################
				# UseValue
				} elsif ( $indexXML->getElementsByTagNameNS( $CLIns, 'UseValue' ) ) {
					my $indexMethod = $indexXML->getElementsByTagNameNS( $CLIns, 'UseValue' )->[0];
					print STDERR "\t\tUses method: UseValue\n" if $debug eq 2;
					$planeIndexes->{ $planeID }->{$index} = 
						newScalarRef (
							$inputs{ 
								$indexMethod->getAttribute( "FormalInputName" )
							}->[0]->{
								$indexMethod->getAttribute( "SemanticElementName" )
							} );
				#############################################################
				# IterateRange
				} elsif ( $indexXML->getElementsByTagNameNS( $CLIns, 'IterateRange' ) ) {
					print STDERR "\t\tUses method: IterateRange\n" if $debug eq 2;
					my $indexMethod = $indexXML->getElementsByTagNameNS( $CLIns, 'IterateRange' )->[0];
					$planeIndexes->{ $planeID }->{$index} = 
						newScalarRef (
							$inputs{ 
								$indexMethod->getElementsByTagNameNS( $CLIns, "Start" )->[0]->getAttribute( "FormalInputName" )
							}->[0]->{
								$indexMethod->getElementsByTagNameNS( $CLIns, "Start" )->[0]->getAttribute( "SemanticElementName" )
							} 
						);
					$planeIndexes->{ $planeID }->{IterateStart}->{$index} = 
						$inputs{ 
							$indexMethod->getElementsByTagNameNS( $CLIns, "Start" )->[0]->getAttribute( "FormalInputName" )
						}->[0]->{
							$indexMethod->getElementsByTagNameNS( $CLIns, "Start" )->[0]->getAttribute( "SemanticElementName" )
						};
					$planeIndexes->{ $planeID }->{IterateEnd}->{$index} = 
						$inputs{ 
							$indexMethod->getElementsByTagNameNS( $CLIns, "End" )->[0]->getAttribute( "FormalInputName" )
						}->[0]->{
							$indexMethod->getElementsByTagNameNS( $CLIns, "End" )->[0]->getAttribute( "SemanticElementName" )
						};
					$planeIndexes->{ $planeID }->{Output}->{$index} = 
						$indexXML->getElementsByTagNameNS( $CLIns, 'IterateRange')->[0];
				}
				#
				#############################################################
				
				print STDERR "\t\tCurrent Value: ". ${ $planeIndexes->{ $planeID }->{$index} } . "\n" if ($debug eq 2) and defined $planeIndexes->{ $planeID }->{$index};
				print STDERR "\t\tIterateStart Value: ". $planeIndexes->{ $planeID }->{IterateStart}->{$index}. "\n" if ($debug eq 2) and defined $planeIndexes->{ $planeID }->{IterateStart}->{$index};
				print STDERR "\t\tIterateEnd Value: ". $planeIndexes->{ $planeID }->{IterateEnd}->{$index}. "\n" if ($debug eq 2) and defined $planeIndexes->{ $planeID }->{IterateEnd}->{$index};
			}
			#	END "Process indexes with non referential methods."
			#################################################################
			
		
			#################################################################
			# helper function - makes a new scalar and returns its reference
			sub newScalarRef { 
				my $tmp = shift;
				return \$tmp;
			}
			
		}
		# End "First run through planes to generate plane indexes"
		#####################################################################
		
		
		#####################################################################
		# Second run through planes to link references
		print STDERR "\n" if $debug eq 2;
		print STDERR "----------------------------------------------\n" if $debug eq 2;
		print STDERR "Second plane run - processing index references\n" if $debug eq 2;
		print STDERR "----------------------------------------------\n" if $debug eq 2;
		foreach my $plane(@planes) {
			my $planeID     = $plane->getAttribute( "XYPlaneID" );
			print STDERR "Processing plane ".$planeID."\n" if $debug eq 2;
			foreach my $index (@planeIndexTypes) {
				my $indexXML    = $plane->getElementsByTagNameNS( $CLIns, $index )->[0];
				print STDERR "\tProcessing index: ".$index."\n" if $debug eq 2;
				if ( $indexXML->getElementsByTagNameNS( $CLIns, 'Match' ) ) {
					my $indexMethod = $indexXML->getElementsByTagNameNS( $CLIns, 'Match' )->[0];
					$planeIndexes->{ $planeID }->{$index} = 
						$planeIndexes->{
							$indexMethod->getAttribute( "XYPlaneID" )
						}->{$index}
						or die "Plane number $planeID.$index references plane number ".$indexMethod->getAttribute( "XYPlaneID" ).".$index but the latter plane's index is not defined. This could be caused by a circular reference.";
					print STDERR "\t\tProcessed reference to plane: ".$indexMethod->getAttribute( "XYPlaneID" )."\n" if $debug eq 2;
				}
				print STDERR "\t\tCurrent Value: ". ${ $planeIndexes->{ $planeID }->{$index} } . "\n" if $debug eq 2;
				print STDERR "\t\tIterateStart Value: ". $planeIndexes->{ $planeID }->{IterateStart}->{$index}. "\n" if ($debug eq 2) and defined $planeIndexes->{ $planeID }->{IterateStart}->{$index};
				print STDERR "\t\tIterateEnd Value: ". $planeIndexes->{ $planeID }->{IterateEnd}->{$index}. "\n" if ($debug eq 2) and defined $planeIndexes->{ $planeID }->{IterateEnd}->{$index};
			}
		}
	#
	# END "Set up Plane Indexes"
	#
	#####################################################################
	
	
	
	
	#####################################################################
	#
	# Execute the module
	#
	my $runAgain;
	my $cmdXML      = $root->getElementsByTagNameNS( $CLIns, "CommandLine" )->[0];
	my @cmdParameters = $cmdXML->getElementsByTagNameNS( $CLIns, "Parameter" )
		if defined $cmdXML;
	my @paramElements;
	@planes = $cmdXML->getElementsByTagNameNS( $CLIns, "XYPlane" )
		if defined $cmdXML;
	print STDERR "\n" if $debug eq 2;
	print STDERR "----------------------\n" if $debug eq 2;
	print STDERR "      Executing\n" if $debug eq 2;
	print STDERR "----------------------\n" if $debug eq 2;
	#
	my $inputStream = '';
	my $outputStream = '';
	my $errorStream = '';
	my @command;
	do { # loop is needed for plane iteration.
		$runAgain         = undef;
		my $cmdLineString = ' ';
		if ($debug) {
			print STDERR "Inputs:";
			foreach my $fi (keys %inputs) {
				print STDERR "\n\t$fi (". scalar @{$inputs{$fi}} .")";
				foreach my $inst ( @{$inputs{$fi}}) {
					foreach my $col ( keys %$inst ) {
						print STDERR "\n\t\t$col => ".$inst->{$col};
					}
					print STDERR "\n";
				}
			}
		}
	
		#################################################################
		#
		# Construct Command Line String
		#
		push (@command, $module->location());
		my $paramString;
		print STDERR "Constructing Command Line String\n" if $debug eq 2;
		foreach my $parameter (@cmdParameters) {
			$paramString = '';
			@paramElements = $parameter->getElementsByTagNameNS( $CLIns, "InputSubString" );
			foreach my $subString (@paramElements) {
				$paramString .= $self->resolveSubString(
					$subString,
					\%inputs,
					$CLIns,
					$session,
					$planeIndexes,
					$imagePix,
					\%dims,
					\%tmpFileFullPathHash,
				);
			}
			push (@command, $paramString);
		}
		#
		#
		#################################################################
			
		#####################################################################
		#   
		# Actually execute
		#  N.B.(IGG): We collect inputs into a scalar then call IPC::Run::run and collect output and error into seperate scalars.
		#  This is not a true pipe, in other words, and neither are modules run in pseudo-ttys.
		#
		print STDERR "Execution string is:\n @command\n" if $debug;

						
			#################################################################
			#
			# Write to STDIN of program
			#
 			my @stdinXML = $root->getElementsByTagNameNS( $CLIns, "STDIN" ); 
			if( @stdinXML ) {
				print STDERR "Writing to Program's STDIN.\n" if $debug eq 2;
				my @inputRecordsXML = $stdinXML[0]->getElementsByTagNameNS( $CLIns, "InputRecord" );
				foreach my $inputRecordXML( @inputRecordsXML ) {
					#construct input record
					my $delimitedRecordXML = [$inputRecordXML->getElementsByTagNameNS( $CLIns,"DelimitedRecord")]->[0];
					my @inputsXML = $delimitedRecordXML->getElementsByTagNameNS( $CLIns, "Input" );
					my @indexesXML = $inputRecordXML->getElementsByTagNameNS( $CLIns, "Index" );

					
					my %recordHash;
					my %knownFormalInputs;
					
					# process each formal input in the record block, & join them on indexes
					foreach my $inputXML( @inputsXML ) {
						my @indexLookup;

						my $location = $inputXML->getAttribute('Location')
							or die "Location attribute not specified in Input element!\n";
						@elements = split (/\./,$location);
						my $FI = shift (@elements);
						
						# have we seen this formal input before?
						next if exists $knownFormalInputs{$FI};
						$knownFormalInputs{$FI} = undef;
						
						# Collect the Location attributes for the Index Input elements who's ST matches the FI.
						foreach my $indexXML (@indexesXML ) {
							foreach ($indexXML->getElementsByTagNameNS( $CLIns,"Input")) {
								@elements = split ( /\./,$_->getAttribute('Location'));
								if ($elements[0] eq $FI) {
									shift (@elements);
									push( @indexLookup, join ('()->',@elements) );
									last;
								}
							}
						}
						
						# make hash entry for each instance of this formal input
						foreach my $input ( @{$inputs{ $FI }} ) {
                            # This doesn't get used, and takes time to build
							#my $d = $input->getDataHash();
							my @keys = ();
							foreach my $se ( @indexLookup ) {
								my $val;
								# FIXME: potential security hole - <Input>'s SemanticElementName needs better type checking at ProgramImport
								eval('$val = $input->'.$se.'()');
								
								die "Could not find SE '$se' belonging to ST '".$input->semantic_type()->name().
									"'. Error: $@. The <InputRecord> was:\n".$inputRecordXML->toString()."\n"
									unless defined $val;
								push( @keys, $val );
							}
							my $key = join( '.', @keys );
							die "Duplicate entry for '$FI' found for index key '$key'\n"
								if exists $recordHash{$key}->{$FI};
							$recordHash{$key}->{$FI} = $input;
						}

					}

					#sort & print input record block
					my @recordBlock;
					foreach my $index( sort keys %recordHash ) {
						my @recordEntries;
						foreach my $inputXML( @inputsXML ) {
							@elements = split ( /\./,$inputXML->getAttribute('Location'));
							my $FI = shift (@elements);
							my $r;
							eval ('$r = $recordHash{ $index }->{ $FI }->'.join ('()->',@elements).'()');
							die "$FI->".join ('()->',@elements)."() returned undef. This was most likely caused by a misspelling of the semantic element in '".$inputXML->toString()."'.\n"
								unless defined $r;
							push( @recordEntries, $r );
						}
						my $record = join( $delimitedRecordXML->getAttribute( 'FieldDelimiter' ), @recordEntries );
						push( @recordBlock, $record );
					}
					my $recordDelimiter = $delimitedRecordXML->getAttribute( 'RecordDelimiter' ) || "\n";
					$inputStream .= join( $recordDelimiter, @recordBlock );
					print STDERR "Record block is:\n".join( $recordDelimiter, @recordBlock ) if $debug eq 2;
				}
			}
			#
			# END 'Write to STDIN of program'
			#
			#################################################################
			# OK, now that we have the inputs, we actually run the module.
			$outputStream='';
			IPC::Run::run (
				\@command,
				\$inputStream,
				\$outputStream,
				\$errorStream
			) or die "module returned non-zero exit status: $?\n$errorStream" ;
			# Forward the error text to our STDERR if there was any.
			print STDERR "module exited normally, but gave the following error output\n".$errorStream if length $errorStream > 0;

		#
		# END 'Actually execute'
		#
		#####################################################################
			
	
	
	


	
			



		#################################################################
		#
		# Iterate plane indexes and write iterated indexes as output
		# 	For a given plane, it's indexes will be iterated like they
		#	were in 3 nested for loops
		#		for(theW...) {
		#			for(theT...) {
		#				for(theZ...) {
		#	Except I'm using an array to hold the indexes so theZ
		#	is $planeIndexTypes[0] and so forth.
		# 
		print STDERR "\tDoing plane iteration and index storage.\n" if $debug eq 2;
		foreach my $plane(@planes) {
			my $planeID = $plane->getAttribute( 'XYPlaneID' );
			print STDERR "\t\tInspecting plane " . $planeID . "\n" if $debug eq 2;
			#########################################################
			#
			# Store indexes that need storing
			#
			foreach my $index (@planeIndexTypes) {
				my $indexXML = $plane->getElementsByTagNameNS( $CLIns, $index )->[0];
				
				foreach my $outputTo ($indexXML->getElementsByTagNameNS( $CLIns, "OutputTo" ) ) {
					@elements = split (/\./,$outputTo->getAttribute( "Location" ) );
					my $foName = $elements[0];
					my $semanticElementName = $elements[1];
					$outputs{ $foName }->{$semanticElementName} = 
						${ $planeIndexes->{ $planeID }->{ $index } };
					print STDERR "\tStored index $index, value ".
						$outputs{ $foName }->{$semanticElementName}.
						" to ".$foName.'.'.$semanticElementName."\n"
						if $debug eq 2;
				}
			}
			#
			#########################################################
	
	
			#########################################################
			#
			# Iterate the first index - typically theZ
			#
			if( ${ $planeIndexes->{ $planeID }->{ $planeIndexTypes[0] } } < $planeIndexes->{ $planeID }->{IterateEnd}->{ $planeIndexTypes[0] } ) {
				$runAgain = 1;
				${ $planeIndexes->{ $planeID }->{ $planeIndexTypes[0] } }++;
				print STDERR "\t\t\tIterated $planeIndexTypes[0]\n" if $debug eq 2;
			#
			#
			#########################################################
			#
			# Iterate the second index - typically theT
			# Also reset theZ if it could use it
			# 	Do this only If theZ didn't need iterating
			#
			} elsif( ${ $planeIndexes->{ $planeID }->{ $planeIndexTypes[1] } } < $planeIndexes->{ $planeID }->{IterateEnd}->{ $planeIndexTypes[1] } ) {
				$runAgain = 1;
				${ $planeIndexes->{ $planeID }->{ $planeIndexTypes[1] } }++;
				print STDERR "\t\t\tIterated $planeIndexTypes[1]\n" if $debug eq 2;
				${ $planeIndexes->{ $planeID }->{ $planeIndexTypes[0] } } = $planeIndexes->{ $planeID }->{IterateStart}->{ $planeIndexTypes[0] }
					if defined $planeIndexes->{ $planeID }->{IterateStart}->{ $planeIndexTypes[0] };
				print STDERR "\t\t\tReset $planeIndexTypes[0] to ".$planeIndexes->{ $planeID }->{IterateStart}->{ $planeIndexTypes[0] }."\n" 
					if ($debug eq 2) and defined $planeIndexes->{ $planeID }->{IterateStart}->{ $planeIndexTypes[0] };
			#
			#
			#########################################################
			#
			# Iterate the third index - typically theW
			# Also reset theT and theZ if they could use it
			# 	Do this only If theZ and theT both didn't need iterating
			#
			} elsif( ${ $planeIndexes->{ $planeID }->{ $planeIndexTypes[2] } } < $planeIndexes->{ $planeID }->{IterateEnd}->{ $planeIndexTypes[2] } ) {
				$runAgain = 1;
				${ $planeIndexes->{ $planeID }->{ $planeIndexTypes[2] } }++;
				print STDERR "\t\t\tIterated $planeIndexTypes[2]\n" if $debug eq 2;
				${ $planeIndexes->{ $planeID }->{ $planeIndexTypes[0] } } = $planeIndexes->{ $planeID }->{IterateStart}->{ $planeIndexTypes[0] }
					if defined $planeIndexes->{ $planeID }->{IterateStart}->{ $planeIndexTypes[0] };
				print STDERR "\t\t\tReset $planeIndexTypes[0] to ".$planeIndexes->{ $planeID }->{IterateStart}->{ $planeIndexTypes[0] }."\n" 
					if ($debug eq 2) and defined $planeIndexes->{ $planeID }->{IterateStart}->{ $planeIndexTypes[0] };
				${ $planeIndexes->{ $planeID }->{ $planeIndexTypes[1] } } = $planeIndexes->{ $planeID }->{IterateStart}->{ $planeIndexTypes[1] }
					if defined $planeIndexes->{ $planeID }->{IterateStart}->{ $planeIndexTypes[1] };
				print STDERR "\t\t\tReset $planeIndexTypes[1] to ".$planeIndexes->{ $planeID }->{IterateStart}->{ $planeIndexTypes[1]}."\n"
					if ($debug eq 2) and defined $planeIndexes->{ $planeID }->{IterateStart}->{ $planeIndexTypes[1] };
			}
			#
			#
			#########################################################
		}
		#
		# END "Iterate plane indexes"
		#
		#################################################################
	
	
		#################################################################
		#   
		# Process output from STDOUT
		#
		my $stdout; $stdout = $root->getElementsByTagNameNS( $CLIns, "STDOUT" )->[0]
			if $root->getElementsByTagNameNS( $CLIns, "STDOUT" );
		my @outputRecords = $stdout->getElementsByTagNameNS( $CLIns, "OutputRecord" )
			if $stdout;
		print STDERR "Collecting output from STDOUT\n" if $debug and $stdout;
		foreach my $outputRecord( @outputRecords) {
			my $repeatCount = $outputRecord->getAttribute( "RepeatCount" );
			my $terminateAt = $outputRecord->getAttribute( "TerminateAt" );
			my $pat = $outputRecord->getElementsByTagNameNS( $CLIns, "pat" )->[0]->getFirstChild->getData();
			my $patRE = qr/$pat/;
			my @outputs = $outputRecord->getElementsByTagNameNS( $CLIns, "Output" );


          KEEP_GOING:
			while( keepGoing($repeatCount, $terminateAt, $outputStream)) {
				print STDERR "$outputStream\n" if $debug eq 2;
				if ($outputStream =~ s/$patRE//) {
					print STDERR "Pattern Match '$patRE'\n" if $debug eq 2;
					$repeatCount-- if defined $repeatCount;
					my @outputRecord;
					foreach my $output(@outputs) {
						foreach my $outputTo ($output->getElementsByTagNameNS( $CLIns, "OutputTo" ) ) {
							# This use of eval is not a security hole. ExecutionInstructions has been validated against XML schema.
							# XML schema dictates AccessBy attribute must be an integer.
							# ...but I'm paranoid, so I'm going to check anyway
							my $accessBy = $output->getAttribute( "AccessBy" );
							die "Attribute AccessBy is not an integer! Execution Instructions in module ".$self->getModule()->name()." are corrupted. Alert system admin!" 
								if( $accessBy =~ m/\D/ );
							@elements = split (/\./,$outputTo->getAttribute( "Location" ) );
							my $foName = $elements[0];
							my $formalOutputColumnName = $elements[1];
							my $cmd                    = '$outputs{ $foName }->{$formalOutputColumnName} = $' . $accessBy . ';';
							eval $cmd;	
						}
					}
				} else {
                    die "Module's output does not match the regular expressions in the ExecutionInstructions";
                    last KEEP_GOING;
                }

				#########################################################
				#   
				# Write output record
				#
				$self->newAttributes(%outputs);
				if($debug) {
					print STDERR "Outputs:";
					foreach my $outputName( keys %outputs) {
						print STDERR "\n\t$outputName:";
							foreach my $outputCol ( keys %{$outputs{$outputName}}) {
								print STDERR "\n\t\t$outputCol: ".$outputs{$outputName}->{$outputCol};
							}
					}
					print STDERR "\n";
				}
				#
				#########################################################

			}
			print STDERR "\n" if $debug eq 2;
			
			#############################################################
			#
			# Helper function
			#	returns undef if loop needs to exit, else returns 1
			#
			sub keepGoing {
				my ($r, $t, $str) = @_;
				return undef if length($str) == 0;
				if( defined $r) {
					return undef if( $r<=0 );
				}
				if(defined $t) {
					return undef if $str =~ m/^$t/;
				}
				return 1;
			}
			#
			#############################################################
		}
		#
		#################################################################
	


		#################################################################
		#   
		# Process Pixel outputs
		#
		my @pixelOutputArray = $root->getElementsByTagNameNS( $CLIns, "PixelOutput" );
		print STDERR "Processing Pixel outputs\n" if $debug and scalar (@pixelOutputArray) > 0;
		foreach my $pixelOutput( @pixelOutputArray) {
			my $foName = $pixelOutput->getAttribute( "FormalOutput" );

			# semantic element names
			my %pixelSEs = map{ $_ => undef} ( 'SizeX', 'SizeY', 'SizeZ', 'SizeC', 'SizeT', 'PixelType' );

			# collect data for semantic elements
			foreach (keys %pixelSEs) {
				# first look in execution instructions
				if ( $pixelOutput->getElementsByTagNameNS( $CLIns, $_ ) ) {
					my $se_xml = $pixelOutput->getElementsByTagNameNS( $CLIns, $_ )->[0];
					# Location: copy data value from an input
					if( $se_xml->getAttribute("Location") ) {
						$pixelSEs{$_} = resolveLocation( $se_xml->getAttribute("Location"), \%inputs );
					# Value: data value is hardcoded
					} elsif( $se_xml->getAttribute("Value") ) {
						$pixelSEs{$_} = $se_xml->getAttribute("Value");
					} else {
						die "Could not find Location or Value in ".$se_xml->toString();
					}
				# next look in outputs hash
				} elsif( exists $outputs{$foName } and exists $outputs{$foName }->{$_} ) {
					$pixelSEs{$_} = $outputs{$foName }->{$_};
				} else {
					die "Could not find Semantic element $_ for PixelsPlane output $foName.";
				}
			}

			# retreive the path of the data file
			my $path; 
			# first look for a temorary file request
			if( $pixelOutput->getElementsByTagNameNS( $CLIns, 'Path' ) ) {
				my $fileID = $pixelOutput->getElementsByTagNameNS( $CLIns, 'Path' )->[0]->getAttribute( 'FileID' );
				$path = $tmpFileFullPathHash{ $fileID };
				die "When processing output $foName, could not lookup Path from FileID $fileID"
					unless $path;
			# next look in outputs hash
			} elsif( exists $outputs{ $foName } and exists $outputs{ $foName }->{'Path'} ) {
				$path = $outputs{ $foName }->{'Path'};			
			} else {
				die "Could not find Semantic element Path for PixelPlane output $foName.";
			}

			# remove this output from the data hash so newAttributes() won't try to create it
			# Pixel outputs get made differently
			delete $outputs{ $foName } if exists $outputs{ $foName };

			# get repository & activate it
			$session->findRepository();
			# upload file
			my $file = OME::Image::Server::File->upload( $path );
			# request new pixels from omeis
			my ($pixels_data, $pixels_attr ) = OME::Tasks::PixelsManager->createPixels(
				$image,
				$self->getModuleExecution(),
				\%pixelSEs
			);
			# issue convert call(s)
			$pixels_data->convert($file,0,OME->BIG_ENDIAN());
			# finish pixels
			OME::Tasks::PixelsManager->finishPixels( $pixels_data, $pixels_attr );

			#########################################################
			#   
			# Write output record
			#
			$self->newAttributes(%outputs);
			if($debug) {
				print STDERR "Outputs:";
				foreach my $outputName( keys %outputs) {
					print STDERR "\n\t$outputName:";
						foreach my $outputCol ( keys %{$outputs{$outputName}}) {
							print STDERR "\n\t\t$outputCol: ".$outputs{$outputName}->{$outputCol};
						}
				}
				print STDERR "\n";
			}
			#
			#########################################################
		}
		#
		#################################################################
	
	
	
	} while($runAgain);
	# END "Execute the module"
	#####################################################################

	# cleanup
	$session->finishTemporaryFile($_) foreach values %tmpFileFullPathHash;
}


#####################################################################
#   
# resolveLocation
#	a helper function to return a scalar given a 'Location' xml attribute
#
sub resolveLocation {
	my $location = shift;
	my $inputs = shift;
	my @elements = split (/\./,$location);
	my $FI = shift (@elements);

	die "Attempting to access a formal input ($FI) that does not exist.\n"
		unless $inputs->{$FI};
	# so far, all 'Location' attributes are in elements that reference
	# a FI of arity 1.
	return $inputs->{$FI}->[0] if( scalar( @elements ) eq 0 );
	my $str = '$inputs->{$FI}->[0]->' . join ('()->',@elements) . '()';
	my $val;
	# FIXME: potential security hole - <Input>'s SemanticElementName needs better type checking at ProgramImport
	eval('$val ='. $str);
	die "Could not resolve input call '$str' from location '$location':\n$@\n"
		unless defined $val;

	return $val;
}
#
#####################################################################

#####################################################################
#   
# resolveSubString
#	a helper function to return a scalar given a <InputSubString>
#	this is the place to add code to handle new types of SubStrings
#
sub resolveSubString {
    my $self = shift;
	my $subString = shift;
	my $inputs = shift;
	my $CLIns = shift;
	my $session = shift;
	my $planeIndexes = shift;
	my $imagePix = shift;
	my $dims = shift;
	my $tmpFileFullPathHash = shift;
			
	#############################################################
	#
	# plain text - no processing required
	#		
	if( $subString->getElementsByTagNameNS( $CLIns, 'RawText' ) ) {
	return $subString->getElementsByTagNameNS( $CLIns, 'RawText' )->[0]->getFirstChild->getData;
	#
	#############################################################
	#
	# Input request
	#
	} elsif ($subString->getElementsByTagNameNS( $CLIns, 'Input' ) ) {
		my $location = $subString->getElementsByTagNameNS( $CLIns, 'Input' )->[0]->getAttribute('Location')
			or die "Location attribute not specified in Input element!\n";
		my $val = resolveLocation( $location, $inputs );

		$val /= $subString->getElementsByTagNameNS( $CLIns, 'Input' )->[0]->getAttribute('DivideBy')
			if defined $subString->getElementsByTagNameNS( $CLIns, 'Input' )->[0]->getAttribute('DivideBy');
		$val *= $subString->getElementsByTagNameNS( $CLIns, 'Input' )->[0]->getAttribute('MultiplyBy')
			if defined $subString->getElementsByTagNameNS( $CLIns, 'Input' )->[0]->getAttribute('MultiplyBy');
		return $val;
	#
	#############################################################
	#
	# PixelsInput
	# FIXME: add support for spewing pixel file contents
	#
	} elsif ($subString->getElementsByTagNameNS( $CLIns, 'PixelsInput' ) ) {
		my $pixelsInput = $subString->getElementsByTagNameNS( $CLIns, 'PixelsInput' )->[0];
		my $location = $pixelsInput->getAttribute('Location')
			or die "Location attribute not specified in PixelsInput element!\n";
		my $substituteWith = $pixelsInput->getAttribute('SubstituteWith')
			or die "SubstituteWith attribute not specified in PixelsInput element!\n";
		my $pixels_attr = resolveLocation( $location, $inputs );
		
		my $pixels_obj = OME::Tasks::PixelsManager->loadPixels( $pixels_attr );
		$tmpFileFullPathHash->{ '__LocalPixels_'.$pixels_obj->getPixelsID() } = $pixels_obj->getTemporaryLocalPixels();
		return $tmpFileFullPathHash->{ '__LocalPixels_'.$pixels_obj->getPixelsID() };
	#
	#############################################################
	#
	# Generate a plane - currently only TIFFs are supported
	#		
	} elsif ($subString->getElementsByTagNameNS( $CLIns, 'XYPlane' ) ) {
		my $planeXML = $subString->getElementsByTagNameNS( $CLIns, 'XYPlane' )->[0];
		my $planeID = $planeXML->getAttribute( 'XYPlaneID' );
		my $planePath = $session->getTemporaryFilename('CLIHandler','TIFF')
			or die "Could not get temporary file to write image plane.";
		my $planeInfo = 'format='.$planeXML->getAttribute( 'Format' ).
			' theZ = '.${ $planeIndexes->{ $planeID }->{theZ} }.
			' theW = '.${ $planeIndexes->{ $planeID }->{theW} }.
			' theT = '.${ $planeIndexes->{ $planeID }->{theT} }.
			' Path = '.$planePath;
		my $pixelsWritten;
		if( $planeXML->getAttribute( 'BPP' ) eq 8 ) {
			$pixelsWritten = $imagePix->Plane2TIFF8( 
			${ $planeIndexes->{ $planeID }->{theZ} },
			${ $planeIndexes->{ $planeID }->{theW} },
			${ $planeIndexes->{ $planeID }->{theT} },
			$planePath,
			1, # scale
			0  # offset
			);
		} else {
			$pixelsWritten = $imagePix->Plane2TIFF( 
			${ $planeIndexes->{ $planeID }->{theZ} },
			${ $planeIndexes->{ $planeID }->{theW} },
			${ $planeIndexes->{ $planeID }->{theT} },
			$planePath );
		}
		my $nPix = $$dims{'x'}*$$dims{'y'};
		die "Wrong number of pixels written to file. $pixelsWritten of $nPix pixels written"
		unless ( $pixelsWritten == $nPix);
		return $planePath;
	#
	#############################################################
	#
	# Request for a temp file
	#		
	} elsif ($subString->getElementsByTagNameNS( $CLIns, 'TempFile' ) ) {
		my $tmpFile = $subString->getElementsByTagNameNS( $CLIns, 'TempFile' )->[0];
		my $tmpFilePath = $session->getTemporaryFilename( 'CLIHandler','' );
		$$tmpFileFullPathHash{ $tmpFile->getAttribute('FileID') } = $tmpFilePath;
		return $tmpFilePath;
	#
	#
	#############################################################
	}
}
#
#####################################################################

sub validateAndProcessExecutionInstructions {
    my ($self, $module, $executionInstructionsXML) = @_;

# Once upon a time this code validated ExecutionInstructions for the CLI handler.
# Back then, the CLI Handler actually worked.
# Some modifications will need to be made (it used to live in ModuleImport.pm)
# but it should serve as a starting point.
#	# verify FormalInputNames, and add ID attributes.
#	my @inputTypes = ( "Input", "UseValue", "End", "Start" );
#	my @inputs;
#	map {
#		push(@inputs, $executionInstructionsXML->getElementsByLocalName( $_ ));
#	} @inputTypes;
#	foreach my $input (@inputs) {
#		my ($formalInputName, $path) = split( /\./, $input->getAttribute( "Location" ), 2 );
#
#		my $formalInput    = $formalInputs{ $formalInputName }
#		  or die "Could not find formal input referenced by element ".$input->tagName()." with FormalInputName ". $input->getAttribute( "FormalInputName");
#		my $semanticType   = $formalInput->semantic_type();
#
#		my $sen = $path;
#		$sen =~ s/^(.*?)\..*$/$1/; # check the SE belonging to this ST, not referenced attributes
#		# i guess ideally, you would trace through the references and do a full sweep.
#		my $semanticElement = $factory->findObject( "OME::SemanticType::Element", semantic_type_id => $semanticType->id(), name => $sen )
#		  or die "Could not find semantic element '$sen' referenced by ".$input->toString().".\n";
#
#		# Create attributes FormalInputID and SemanticElementID
#		# also create FormalInputName and SemanticElementName to work with CLIHandler code
#		# maybe should change CLIHandler code sometime?
#		$input->setAttribute ( "FormalInputName", $formalInputName );
#		$input->setAttribute ( "SemanticElementName", $path );
#		$input->setAttribute ( "FormalInputID", $formalInput->id() );
#		$input->setAttribute ( "SemanticElementID", $semanticElement->id() );
#
#	}
#
#	# verify outputs, and add ID attributes.
#	my @outputTypes = ( "OutputTo", "AutoIterate", "IterateRange" );
#	my @outputs;
#	map {
#		push(@outputs, $executionInstructionsXML->getElementsByLocalName( $_ ));
#	} @outputTypes;
#
#	foreach my $output (@outputs) {
#		my ($formalOutputName, $sen) = split( /\./, $output->getAttribute( "Location" ) );
#
#		my $formalOutput    = $formalOutputs{ $formalOutputName }
#		  or die "Could not find formal output referenced by element ".$output->tagName()." with FormalOutputName ". $output->getAttribute( "FormalOutputName");
#		my $semanticType   = $formalOutput->semantic_type();
#		my $semanticElement = $factory->findObject( "OME::SemanticType::Element", semantic_type_id => $semanticType->id(), name => $sen )
#		  or die "Could not find semantic column referenced by element ".$output->tagName()." with SemanticElementName ".$output->getAttribute( "SemanticElementName" );
#
#		# Create attributes FormalOutputID and SemanticElementID to store NAME and FORMAL_OUTPUT_ID
#		$output->setAttribute ( "FormalOutputName", $formalOutputName );
#		$output->setAttribute ( "SemanticElementName", $sen );
#		$output->setAttribute ( "FormalOutputID", $formalOutput->id() );
#		$output->setAttribute ( "SemanticElementID", $semanticElement->id() );
#
#	}
#
#	# normalize XYPlaneID's
#	my $currentID = 0;
#	my %idMap;
#	# first run: normalize XYPlaneID's in XYPlane's
#	foreach my $plane ($executionInstructionsXML->getElementsByLocalName( "XYPlane" ) ) {
#		$currentID++;
#		die "Two planes found with same ID (".$plane->getAttribute('XYPlaneID').")"
#		  if ( defined defined $plane->getAttribute('XYPlaneID') ) and ( exists $idMap{ $plane->getAttribute('XYPlaneID') } );
#		$idMap{ $plane->getAttribute('XYPlaneID') } = $currentID
#		  if defined $plane->getAttribute('XYPlaneID');
#		$plane->setAttribute('XYPlaneID', $currentID);
#	}
#	# second run: clean up references to XYPlanes
#	foreach my $match ( $executionInstructionsXML->getElementsByLocalName( "Match" ) ) {
#		die "'Match' element's reference plane not found. XYPlaneID=".$match->getAttribute('XYPlaneID').". Did you make a typo?"
#			unless exists $idMap{ $match->getAttribute('XYPlaneID') };
#		$match->setAttribute('XYPlaneID',
#			 $idMap{ $match->getAttribute('XYPlaneID') } );
#	}
#	
#	# check regular expressions for validity
#	my @pats =  $executionInstructionsXML->getElementsByLocalName( "pat" );
#	foreach (@pats) {
#		my $pat = $_->getFirstChild->getData();
#		eval { "" =~ /$pat/; };
#		die "Invalid regular expression pattern: $pat in module ".$newProgram->name()
#		  if $@;
#	}

	return $executionInstructionsXML;
}

1;
