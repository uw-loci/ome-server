# OME/Install/LDAPConfigTask.pm
# This task builds and installs OME LDAP integration

#-------------------------------------------------------------------------------
#
# Copyright (C) 2006 Open Microscopy Environment
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
#    Author: Mike McCaughey
#            Vanderbilt University School of Medicine
#            mike.mccaughey@vanderbilt.edu
#            V 0.95a 30 Jun 06
#            Simplification of original code by IGG <igg@nih.gov> 2007-08-01
#-------------------------------------------------------------------------------
package OME::Install::LDAPConfigTask;

#*********
#********* INCLUDES
#*********

use strict;
use warnings;
use Carp;
use English;
use Term::ANSIColor qw(:constants);

use Cwd;

use OME::Install::Util;
use OME::Install::Environment;
use OME::Install::PerlModuleTask;

use OME::Session;
use base qw(OME::Install::InstallationTask);


#*********
#********* GLOBALS AND DEFINES
#*********

# Default package repository
my $REPOSITORY = "http://openmicroscopy.org/packages/perl";

# Global logfile filehandle and name
my $LOGFILE_NAME = "LDAPConfigTask.log";
my $LOGFILE;

# Our basedirs and user which we grab from the environment
my ($OME_TMP_DIR, $USERNAME);
my $LDAP;

# Installation home
my $INSTALL_HOME;
my $ENVIRONMENT;

sub execute {
	# This is eval'ed because it contains a dependency on Term::ReadKey which
	# May not be resolved for other parts of the installer, but is required
	# at this point.
    eval "use OME::Install::Terminal";
    croak "Errors loading module: $@\n" if $@;

	my $retval;
	
	# Our OME::Install::Environment
    my $environment = initialize OME::Install::Environment;
    $ENVIRONMENT = $environment;

    # Set our globals
    $OME_TMP_DIR = $environment->tmp_dir()
		or croak "Unable to retrieve OME_TMP_DIR!";
	$USERNAME = $environment->ome_exper()->{OMEName} if $environment->ome_exper()
		or croak "Unable to retrieve OME Experimenter from installation environment!";

    # Store our IWD so we can get back to it later
    my $iwd = getcwd ();

    # Set our installation home
    $INSTALL_HOME = "$OME_TMP_DIR/install";
    
	#
	# LDAP HASH CONFIG VARS
	#
	my $LDAP_CONF_DEF = {
		configure  => 0, # If set, a check will be made
		configured => 0, # Only set when things check out
		use        => 0, # Will be unset if check doesn't pass.
# 		hosts      => [
# 			'ldaps://lincon.grc.nia.nih.gov:636',
# 			'ldaps://lincon2.grc.nia.nih.gov:636',
# 			'ldap://lincon.grc.nia.nih.gov:389', # In this example, TLS will be attempted on only this server
# 		],
		hosts       => guess_URIs(),
		options    => {
# Unless this becomes necessary, I don't think we need this as a setting (IGG)
#			debug     => undef,
			version   => 3,
			timeout   => 10,
			onerror   => 'die', # Not user configurable at this time
			async     => 0, # Not user configurable
		},
		use_tls    => 1, # This only takes effect if the connection is unencrypted and the server supports TLS
	# These options apply to all SSL connections (ldaps schemes and TLS)
		ssl_opts   => {
			sslversion => undef, # 'sslv2' | 'sslv3' | 'sslv2/3' | 'tlsv1', not user configurable
			capath     => undef,
#			cafile     => '/etc/nialdap/cacerts/niairpCAcert.crt',
			cafile     => undef,
			ciphers    => 'ALL',
			verify     => 'require', # 'none' | 'optional' | 'require'
			clientcert => undef,
			clientkey  => undef,
		},
		DN       => guess_DN(),
#		DN       => 'ou=people,ou=nia,o=nih,c=us',
		
	};
# 	my $LDAP_CONF_DEF = {
# 		USE_LDAP     		=> 0,
# 		USE_SSL      		=> 0,
# 		USE_LDAP_ASYNC     	=> 0,
# 		USE_TLS			    => 0,
# 		USE_CA				=> 0,
# 		LDAP_ALLOW_LOCAL	=> 1,
# 		LDAP_URIs			=> [], # Array of URIs in the format ldap[s]://my.server.org:389
# 		LDAP_PORT			=> 0, Port is specified in the URIs
# 		LDAP_OU			=> 'ou=people',
# 		LDAP_DC			=> 'dc=vanderbilt,dc=edu',
# 		LDAP_ONERROR		=> 'die',
# 		LDAP_TIMEOUT		=> 10,
# 		LDAP_DEBUG			=> 0,
# 		LDAP_VER			=> 3,
# 		LDAP_VERIFY			=> 'none',
# 		LDAP_SSL_VER		=> 'sslv2/3',
# 		LDAP_CIPHER			=> 'ALL',
# 		LDAP_CERT			=> undef,
# 		LDAP_CAPATH			=> undef,
# 		LDAP_CAFILE			=> undef,
# 
# 	};
	$LDAP = defined $environment->ldap_conf()  ? $environment->ldap_conf()  : $LDAP_CONF_DEF;
	# for testing of bind()
	my ($username,$passwd);
	# This will hold the LDAP_EXTENSION_START_TLS constant from the quoted eval once we have the pre-reqs
	my $can_tls;

	print "\n";
	print_header ("Optional LDAP installation");
	print "If configured for authentication, all OME users will initially be authenticated by LDAP.\n";
	print "If LDAP authentication fails, local authentication will be attempted if the user has a local password.\n";
	print "(All verbose information logged in $INSTALL_HOME/$LOGFILE_NAME)\n\n";

    # Get our logfile and open it for reading
    open ($LOGFILE, ">", "$INSTALL_HOME/$LOGFILE_NAME")
		or croak "Unable to open logfile \"$INSTALL_HOME/$LOGFILE_NAME\".$!";

	# Confirm all flag
	my $confirm_all;
	
	while (1) {
		if ($environment->get_flag("UPDATE") or $confirm_all or $LDAP->{configured}) {
					
			# Ask user to confirm his/her original entries
			print BOLD,"LDAP Configuration:\n",RESET;
			print "               Configure LDAP?: ", BOLD, $LDAP->{configure} ? 'yes':'no', RESET, "\n";
			print "  Use LDAP for Authentication?: ", BOLD, $LDAP->{use} ? 'yes':'no', RESET, "\n";
			print "           OME Users DN Suffix: ", BOLD, $LDAP->{DN} ? $LDAP->{DN} : 'undefined', RESET, "\n";
			print "       LDAP connection timeout: ", BOLD, $LDAP->{options}->{timeout}, RESET, "\n";
#			print "              LDAP debug level: ", BOLD, $LDAP->{options}->{debug} ? $LDAP->{options}->{debug} : 'undefined', RESET, "\n";
			print "           LDAP server version: ", BOLD, $LDAP->{options}->{version}, RESET, "\n";
			print "        Use TLS when possible?: ", BOLD, $LDAP->{use_tls} ? 'yes':'no', RESET, "\n";
			print BOLD,"Global SSL options",RESET," (TLS or ldaps:// host URIs):\n",RESET;
			print "     Verify server certificate: ", BOLD, $LDAP->{ssl_opts}->{verify}, RESET, "\n";
			print "             Permitted ciphers: ", BOLD, $LDAP->{ssl_opts}->{ciphers}, RESET, "\n";
			print "    Path to server certificate: ", BOLD, $LDAP->{ssl_opts}->{capath} ? $LDAP->{ssl_opts}->{capath} : 'undefined', RESET, "\n";
			print "   File for server certificate: ", BOLD, $LDAP->{ssl_opts}->{cafile} ? $LDAP->{ssl_opts}->{cafile} : 'undefined', RESET, "\n";
			print "    Path to client certificate: ", BOLD, $LDAP->{ssl_opts}->{clientcert} ? $LDAP->{ssl_opts}->{clientcert} : 'undefined', RESET, "\n";
			print "            Path to client key: ", BOLD, $LDAP->{ssl_opts}->{clientkey} ? $LDAP->{ssl_opts}->{clientkey} : 'undefined', RESET, "\n";
			print BOLD,"Configured LDAP URIs:\n",RESET;
			print "\t$_\n" foreach (@{$LDAP->{hosts}});
			print "\n";  # Spacing

			y_or_n ("Are these values correct ?",'y') and last;
		}
		
		print "To make an option un-defined, enter '-' (without quotes). To leave an option as is, press return\n";
		if (y_or_n ("Configure LDAP?",'y') and check_LDAP_packages()) {
			# This is a string eval so we don't use/require these packages until we've run check_LDAP_packages
			eval 'use Net::LDAP; use Net::LDAP::Constant qw(LDAP_EXTENSION_START_TLS); $can_tls = LDAP_EXTENSION_START_TLS;';

			$LDAP->{configure} = 1;
			if (y_or_n ("Use LDAP for authentication?",$LDAP->{use} ? 'y' : 'n') ) {$LDAP->{use} = 1;}
			else {$LDAP->{use} = 0;}
			print "A DN suffix is used to identify all OME users on the LDAP server\n";
			print "The DN for authentication (LDAP bind) consists of 'uid=', the username, a ',' and the DN suffix\n";
			print "Typical DN suffixes may be 'ou=people,ou=nia,o=nih,c=us' or 'ou=people,dc=vanderbilt,dc=edu'\n";
			$LDAP->{DN} = confirm_default ("LDAP DN suffix for OME users:", $LDAP->{DN});
			$LDAP->{DN} = undef if $LDAP->{DN} and $LDAP->{DN} eq '-';
			$LDAP->{options}->{timeout} = confirm_default ("LDAP connection timeout:", $LDAP->{options}->{timeout});
#			$LDAP->{options}->{debug} = confirm_default ("Net::LDAP debug level (output to Apache error log):", $LDAP->{options}->{debug});
#			$LDAP->{options}->{debug} = undef if $LDAP->{options}->{debug} and $LDAP->{options}->{debug} eq '-';
			$LDAP->{options}->{version} = confirm_default ("LDAP protocol version:", $LDAP->{options}->{version});
			if (y_or_n ("Use Transport Layer Security (TLS) when possible and appropriate?",'y') ) {$LDAP->{use_tls} = 1;}
			else {$LDAP->{use_tls} = 0;}
			my $verify = '';
			while (not ($verify eq 'none' or $verify eq 'optional' or $verify eq 'require')){
				$verify = confirm_default ("LDAP server SSL certificate verification (none, optional or require):", $LDAP->{ssl_opts}->{verify});
			}
			$LDAP->{ssl_opts}->{verify} = $verify;
			$LDAP->{ssl_opts}->{ciphers} = confirm_default ("LDAP SSL permitted ciphers (use the 'openssl ciphers' command for full list):", $LDAP->{ssl_opts}->{ciphers});
			print BOLD,"Server and client certificate locations\n",RESET;
			print "The Net::LDAP documentation under start_tls may be helpful.\n";
			print "Type 'perldoc Net::LDAP' in a new terminal window for help.\n";
			$LDAP->{ssl_opts}->{capath} = confirm_default ("Path to directory containing LDAP server CA certificates (capath):", $LDAP->{ssl_opts}->{capath});
			$LDAP->{ssl_opts}->{capath} = undef if $LDAP->{ssl_opts}->{capath} and $LDAP->{ssl_opts}->{capath} eq '-';
			$LDAP->{ssl_opts}->{cafile} = confirm_default ("Path to file containing the LDAP server's CA certificate (cafile):", $LDAP->{ssl_opts}->{cafile});
			$LDAP->{ssl_opts}->{cafile} = undef if $LDAP->{ssl_opts}->{cafile} and $LDAP->{ssl_opts}->{cafile} eq '-';
			$LDAP->{ssl_opts}->{clientcert} = confirm_default ("Path to client certificate (clientcert):", $LDAP->{ssl_opts}->{clientcert});
			$LDAP->{ssl_opts}->{clientcert} = undef if $LDAP->{ssl_opts}->{clientcert} and $LDAP->{ssl_opts}->{clientcert} eq '-';
			$LDAP->{ssl_opts}->{clientkey} = confirm_default ("Path to client certificate key (clientkey):", $LDAP->{ssl_opts}->{clientkey});
			$LDAP->{ssl_opts}->{clientkey} = undef if $LDAP->{ssl_opts}->{clientkey} and $LDAP->{ssl_opts}->{clientkey} eq '-';

			print BOLD,"LDAP Server Configuration:\n",RESET;
			print "Each LDAP server is listed as a URI, specifying ldap:// or ldaps://, and an optional port.  Examples:\n";
			print "\tldaps://ldap.foo.org\n";
			print "\tldap://ldap2.foo.org:636\n";
			print "During LDAP authentication, the URIs in the list will be tried in order until a connection is made.\n";
			print "During this setup, the URIs will be tested for functionality as you enter them.\n";
			print "Enter a username and password that will authenticate with your LDAP server(s)\n";
			$username = confirm_default("LDAP username to test: ", $USERNAME);
			($passwd,undef) = get_password ('Password: ',1);
			my @URIs;
			my $num=0;
			while (1) {
				my $uri = undef;
				$uri = $LDAP->{hosts}->[$num] if (scalar (@{$LDAP->{hosts}}) > $num);
				$num++;
				$uri = confirm_default ("Enter an LDAP URI, or '-' to end:", $uri);
				last unless $uri;
				last if $uri eq '-';
				my $ldap;
				eval {
					$ldap = Net::LDAP->new ( $uri, %{$LDAP->{options}},%{$LDAP->{ssl_opts}} );
				};
				if ($ldap) {
					print "Connected to URI $uri\n";
					print $LOGFILE "Connected to URI $uri\n";
					print "cypher: ",$ldap->cipher ( ) ? $ldap->cipher ( ) : 'NONE',"\n";
					print $LOGFILE "cypher: ",$ldap->cipher ( ) ? $ldap->cipher ( ) : 'NONE',"\n";
					if (not $ldap->cipher()
						and $ldap->root_dse()->supported_extension ($can_tls)
						) {
							print "Trying TLS... ";
							print $LOGFILE "Trying TLS... ";
							eval {
								$ldap->start_tls(%{$LDAP->{ssl_opts}});
							};
							if ($ldap->cipher ( )) {
								print BOLD, "[SUCCESS]", RESET, ". Cypher: ".$ldap->cipher ( )."\n";
								print $LOGFILE "Success.  Cypher: ".$ldap->cipher ( )."\n";
								if (not $LDAP->{use_tls}) {
									print "This server supports TLS, but you have not enabled this option.  It is highly recommended to do so.\n";
									$LDAP->{use_tls} = 1 if y_or_n( "Enable 'Use TLS' so that passwords are not sent as clear text?",'y');
									print $LOGFILE "Enabled use_tls.\n" if $LDAP->{use_tls};								
								}
							} else {
								print BOLD, "[FAILURE]", RESET, ":\n$@\n";
								print $LOGFILE "Failure:\n$@\n";								
								if ($LDAP->{use_tls}) {
									print $LOGFILE "The Use TLS option is enabled, TLS is supported by the server, but could not be established.\n";
									print "The Use TLS option is enabled, TLS is supported by the server, but could not be established.\n";
									print "You will need to fix the SSL options, disable 'Use TLS', or remove this server from the list.\n";
									print "LDAP authentication *WILL NOT BE ATTEMPTED* to this server using the current configuration.\n";
								}
							}
					} elsif (not $ldap->cipher() and $LDAP->{use_tls}) {
					# We can't use a server that does not support TLS if Use TLS is enabled.
						print $LOGFILE "The Use TLS option is enabled, but the server does not support it.\n";
						print "The 'Use TLS' option is enabled, but this server does not support it.\n";
						print "LDAP authentication *WILL NOT BE ATTEMPTED* to this server, and it should not be on the list.\n";
					}
					# The only way we attempt a bind is either over an encrypted connection or if the user
					# specified to not use TLS.
					if ($username and $passwd and ($ldap->cipher() or not $LDAP->{use_tls}) ) {
						# Try to bind to the host
						print "Authenticating $username to $uri...";
						my $DN = "uid=$username";
						$DN .= ",$LDAP->{DN}" if $LDAP->{DN};
						my $mesg;
						eval{$mesg = $ldap->bind ($DN, password => $passwd );};
						if ($@ or not $mesg or $mesg->code != 0) {
							print BOLD, "[FAILURE]", RESET, "\n$@\n";
							print $LOGFILE "Failed bind '$DN' to '$uri':\n$@\n";
						} else {
							print BOLD, "[SUCCESS]", RESET, ".\n";
							print $LOGFILE "Successful bind '$DN' to '$uri'\n";
							$ldap->unbind ( );
						}
					} elsif ($username and $passwd) {
						print "Authentication test skipped over an unencrypted connection\n";
						print "If this is the only active server in the URI list, LDAP authentication will not work!\n";
						print $LOGFILE "Authentication test skipped over an unsecure connection\n";
					} else {
						print "Authentication test skipped  - no username/password supplied\n";
						print $LOGFILE "Authentication test skipped over an unsecure connection\n";
					}
					$ldap->disconnect();
				} else {
					print "Failed to connect to URI $uri:\n$@\n";
					print $LOGFILE "Failed to connect to URI $uri:\n$@\n";
				}

				push (@URIs,$uri) if (y_or_n ("Keep $uri in URI list?",'y') );
			}
			
			# @URIs now has good hosts
			if (scalar @URIs) {
				$LDAP->{hosts} = [@URIs];
				$LDAP->{configured} = 1;
				print $LOGFILE "LDAP configured with URIs:\n", join ("\n",@URIs),"\n";
			} else {
				$LDAP->{configured} = 0;
				$LDAP->{use} = 0;
				print $LOGFILE "No URIs. LDAP is not configured and will not be used\n";
			}
		} else {
			$LDAP->{configure} = 0;
			$LDAP->{configured} = 0;
			$LDAP->{use} = 0;
		}
		print "\n";  # Spacing
		$confirm_all = 1;
	}
	
	# Test the LDAP configuration for inconsistencies
	# We can't use it if its not configured
	$LDAP->{use} = 0 if ($LDAP->{use} and not $LDAP->{configured});

	# We can't use it if we can't load Net::LDAP
	eval 'use Net::LDAP; use Net::LDAP::Constant qw(LDAP_EXTENSION_START_TLS); $can_tls = LDAP_EXTENSION_START_TLS;';
	if ($@) {
		print "Net::LDAP could not be loaded - LDAP authentication will not be used\n";
		$LDAP->{use} = 0;
		$LDAP->{configured} = 0;
	}

	# If we intend to use it, see if we can connect
	if ($LDAP->{use}) {
		print "Testing LDAP configuration... ";
		my $ldap;
		eval {
			$ldap = Net::LDAP->new ( $LDAP->{hosts}, %{$LDAP->{options}},%{$LDAP->{ssl_opts}} );
		};
		if ($ldap) {
			print BOLD, "[CONNECTED]", RESET,"\n";
			if (not $ldap->cipher()
				and $ldap->root_dse()->supported_extension ($can_tls)
				and $LDAP->{use_tls}
				) {
					print "Starting TLS... ";
					eval {
						$ldap->start_tls(%{$LDAP->{ssl_opts}});
					};
					if ($ldap->cipher()) {
						print BOLD, "[SUCCESS]", RESET,"\n";
						print $LOGFILE "TLS successful\n";
					} else {
						print BOLD, "[FAILED]", RESET,":\n$@\n";
						print "LDAP authentication will be attempted, but is not likely to work!\n";
						print $LOGFILE "TLS failed:\n$@\n";
					}
				} elsif (not $ldap->cipher() and $LDAP->{use_tls}) {
					print BOLD, "[TLS UNSUPPORTED!]", RESET,"\n";
					print "LDAP authentication will be attempted, but is not likely to ever work!\n";
					print $LOGFILE "TLS is requested but not supported!!\n";
				}
			if ($username and $passwd and ($ldap->cipher() or not $LDAP->{use_tls}) ) {
				# try the bind
				print "Attempting to bind to LDAP server...";
				my $DN = "uid=$username";
				$DN .= ",$LDAP->{DN}" if $LDAP->{DN};
				my $mesg;
				eval{$mesg = $ldap->bind ($DN, password => $passwd );};
				if ($@ or not $mesg or $mesg->code != 0) {
					print BOLD, "[FAILURE]", RESET, ":\n$@.\n";
					print $LOGFILE "Failed bind '$DN': $@\n";
				} else {
					print BOLD, "[SUCCESS]", RESET, ".\n";
					print $LOGFILE "Successful bind '$DN'\n";
					$ldap->unbind ( );
				}
			} elsif ($username and $passwd) {
				print "Authentication test skipped over an unencrypted connection\n";
				print "LDAP authentication will be attempted, but it is not likely to ever work!\n";
				print $LOGFILE "Authentication test skipped over an unsecure connection\n";
			} else {
				print "Authentication test skipped  - no username/password supplied\n";
				print $LOGFILE "Authentication test skipped over an unsecure connection\n";
			}
			$ldap->disconnect();
		} else {
			print BOLD, "[FAILED TO CONNECT]", RESET,"\n";
			print $LOGFILE "Could not connect to any LDAP host\n";
		}
	}
	# The reader's digest of the above connection logic.
	# This is what's used in OME::SessionManager::authenticate_LDAP()
# 	my ($username,$passwd);
# 	my $can_tls;
# 	if ($LDAP->{use}) {
# 		# This is a quoted eval because we wnat this processed only if $LDAP->{use}
# 		eval 'use Net::LDAP;';
# 		if ($@) {
# 			# Can't use Net::LDAP - abort!
# 		}
# 		eval { $ldap = Net::LDAP->new ( $LDAP->{hosts}, %{$LDAP->{options}},%{$LDAP->{ssl_opts}} ); };
# 		if ($ldap) {
# 			# Start TLS if requested (no point in checking now if the server supoprts it)
# 			eval { $ldap->start_tls(%{$LDAP->{ssl_opts}}); }
# 				if ( not $ldap->cipher() and $LDAP->{use_tls} );
# 			# The only way we send credentials is over an encrypted connection or if use_tls is off
# 			if ($username and $passwd and ($ldap->cipher() or not $LDAP->{use_tls}) ) {
# 				my $DN = "uid=$username";
# 				$DN .= ",$LDAP->{DN}" if $LDAP->{DN};
# 				my $mesg;
# 				eval{$mesg = $ldap->bind ($DN, password => $passwd );};
# 				if ($@ or not $mesg or $mesg->code != 0) {
# 					# Authentication failed
# 					#...
# 				} else {
# 					# Authentication succeeded
# 					#...
# 					# Don't forget to unbind
# 					$ldap->unbind ( );
# 				}
# 			} else {
# 				# Authentication not attempted: no user/pass or unsecure.  This counts as failure.
# 			}
# 			# Don't forget to disconnect
# 			$ldap->disconnect();
# 		} else {
# 			# Couldn't connect to LDAP server:  This counts as failure.
# 		}
# 	}

	
	
	# Store the ldap conf in the environment
	$environment->ldap_conf($LDAP);
	$environment->store_to();
	my $session = OME::Session->instance() if OME::Session->hasInstance();
	if ($session) {
		my $configuration = $session->Configuration;
		$configuration->ldap_conf($LDAP);
	    $session->commitTransaction();
	} else {
		print "Could not re-connect to the OME Session used during installation\n";
		print $LOGFILE "Could not re-connect to the OME Session used during installation\n";
	}

	return 1;
}

sub check_LDAP_packages {
	my @modules = (
		{
		# Convert::ASN1 is required for Net::LDAP
		name => 'Convert::ASN1',
		repository_file => "$REPOSITORY/Convert-ASN1-0.20.tar.gz",
		},{
		# Digest::HMAC_MD5 is required for Authen::SASL
		name => 'Digest::HMAC_MD5',
		repository_file => "$REPOSITORY/Digest-HMAC-1.01.tar.gz",
		},{
		# GSSAPI is required for Authen::SASL
		name => 'GSSAPI',
		repository_file => "$REPOSITORY/GSSAPI-0.24.tar.gz",
		},{
		# Authen::SASL is required for Net::LDAP
		name => 'Authen::SASL',
		repository_file => "$REPOSITORY/Authen-SASL-2.10.tar.gz",
		},{
		# Net::SSLeay is required for IO::Socket::SSL
		name => 'Net::SSLeay',
		repository_file => "$REPOSITORY/Net_SSLeay.pm-1.30.tar.gz",
		# Stupidly, Net::SSLeay testing requires interaction, so no test for you
		skip_test => 1,
		},{
		# IO::Socket::SSL is required for Net::LDAPS
		name => 'IO::Socket::SSL',
		repository_file => "$REPOSITORY/IO-Socket-SSL-0.999.tar.gz",
		},{
		# XML::Filter::BufferText is required for XML::SAX::Writer
		name => 'XML::Filter::BufferText',
		repository_file => "$REPOSITORY/XML-Filter-BufferText-1.01.tar.gz",
		},{
		# Text::Iconv is required for XML::SAX::Writer
		name => 'Text::Iconv',
		repository_file => "$REPOSITORY/Text-Iconv-1.4.tar.gz",
		},{
		# XML::SAX::Writer is required for Net::LDAP
		name => 'XML::SAX::Writer',
		repository_file => "$REPOSITORY/XML-SAX-Writer-0.50.tar.gz",
		},{
		name => 'Net::LDAP',
		repository_file => "$REPOSITORY/perl-ldap-0.34.tar.gz",
		}
	);
	
	# We're going to use OME::Install::PerlModuleTask::execute to do all of our work.
	# To do this, we have to change this packages module list,
	# and set the 'PERL_CHECK' flag in the environment.
	# to be good citizens, we will set these back to what they were before returning.
	my $perl_check = $ENVIRONMENT->get_flag ("PERL_CHECK");
	$ENVIRONMENT->set_flag ('PERL_CHECK');

	my @saved_modules = @OME::Install::PerlModuleTask::modules;
	@OME::Install::PerlModuleTask::modules = @modules;

	my $result;
	eval {
		$result = OME::Install::PerlModuleTask::execute();
	};
	
	if ($perl_check) {
		$ENVIRONMENT->set_flag ('PERL_CHECK');
	} else {
		$ENVIRONMENT->unset_flag ('PERL_CHECK');
	}
	@OME::Install::PerlModuleTask::modules = @saved_modules;
	
	return $result;
}

sub guess_DN {
	my $DN = `grep -i base /etc/ldap.conf 2>/dev/null`;
	$DN = undef if $DN =~ /^\s*#/;
	$DN = `grep -i base /etc/openldap/ldap.conf 2>/dev/null` unless $DN;
	return undef unless $DN;
	return undef if $DN =~ /^\s*#/;

	$DN = $1 if $DN =~ /base\s+(.*)$/i;
	$DN =~ s/\s+$// if $DN;
	$DN = "ou=people,$DN" if $DN and not $DN =~ /^ou=people/;

	return $DN
}


sub guess_URIs {
	my @grepURIs = `grep -i uri /etc/ldap.conf 2>/dev/null`;
	my @grep2URIs = `grep -i uri /etc/openldap/ldap.conf 2>/dev/null`;
	push (@grepURIs,@grep2URIs);
	my @URIs;
	foreach my $URI (@grepURIs) {
		next if $URI =~ /^\s*#/;
		$URI = $1 if $URI =~ /uri\s+(.*)$/i;
		$URI =~ s/\s+$// if $URI;
		push (@URIs,split (/\s+/,$URI)) if $URI;
	}

	return \@URIs;
}

sub rollback {
    croak "Rollback!\n";

    # Stub for the moment.
    return 1;
}

1;

