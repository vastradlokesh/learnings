use strict;
use warnings;

use XML::LibXML;

################################################################################
# Author : Lokesh M Vastrad

# Perl Script to read an input xml file and update Multiple target xml files
# by reading the values from the input file. The input file and all the target
# xml files should be in the same directory
#################################################################################

my $env = $ARGV[0];

if(!$ARGV[0])
	{
		usage();
	}

my (@apps, @paths, @arr,@specificapp,@filestoopen,$app,$property,$path,$file1);

my $parser = XML::LibXML->new();
my $doc    = $parser->parse_file('inputfile.xml');

#loop to get the application names from input file
for my $node ($doc->findnodes('/substitutions/application/@name')) 
{

	my @nodes =  split ('=', $node->toString);
	push @apps, $nodes[1];
	@arr = split ("", @apps);

}

foreach my $app (@apps) 

{
	$app =~ tr/"//d;
	push (@specificapp, $app);

}

#Main loop which checks for multiple conditions and updates the xml files
foreach my $specificapp(@specificapp) 
	
	{

		my $abc = $specificapp;
		my $parser1 = XML::LibXML->new();
		my $doc1=$parser1->parse_file('inputfile.xml');


			for my $application ($doc1->findnodes("/substitutions/application[\@name = '$abc']/file/\@path"))
				{
					my @applications =  split ('=', $application->toString);
					$path = $applications[1] . "\n";
					$path =~ tr/"//d;
					chomp $path;
					
				for my $propertyname ($doc1->findnodes("/substitutions/application[\@name = '$abc']/file[\@path = '$path']/property/\@name"))
					{
						my @propertynames =  split ('=', $propertyname->toString);
						$property = $propertynames[1] . "\n";
						$property =~ tr/"//d;
						chomp $property;
					
						 for my $envname ($doc1->findnodes("/substitutions/application[\@name = '$abc']/file[\@path = '$path']/property[\@name = '$property']/env[\@name='$ARGV[0]']"))
							{
								my $result = $envname->toString;
								my $result1 = $envname->to_literal;
								$file1 = "myfile-$abc-substitutions.xml";
								my $parser2 = XML::LibXML->new();
								my $doc2=$parser2->parse_file("$file1");
								
								#loop to check for filepath existance in the target file, if not updates the filepath along with Property and env value
								for my $new_items3 ($doc1->findnodes("/substitutions/application[\@name = '$abc']/file[\@path='$path']"))
								{
									my $message3 = qq|\t<file path="$path">\n\t<property name="$property" provider="ENGG">\n\t\t$result\n\t</property>\n\t</file>|;
									if (! $doc2->exists("/substitutions/application[\@name = '$abc']/file[\@path='$path']"))
									{
										my($book3)=$doc2->findnodes("/substitutions/application[\@name = '$abc']");
											  my $fragment3 = $parser2->parse_balanced_chunk("$message3\n");
											  $book3->appendChild($fragment3);
												open my $out_fh, '>', $file1;
												print {$out_fh} $doc2->toString;
												close($out_fh);
									}

								#loop to check for property existance in the target file, if not updates the Property and env value
								for my $new_items2 ($doc1->findnodes("/substitutions/application[\@name = '$abc']/file[\@path = '$path']/property[\@name = '$property']"))
								{
						
									my $message2 = qq|\t<property name="$property" provider="ENGG">\n\t\t$result\n\t</property>|;
									if (! $doc2->exists("/substitutions/application[\@name = '$abc']/file[\@path = '$path']/property[\@name = '$property']"))
									{
										my($book2)=$doc2->findnodes("/substitutions/application[\@name = '$abc']/file[\@path = '$path']");
											  my $fragment2 = $parser2->parse_balanced_chunk("$message2\n");
											  $book2->appendChild($fragment2);
												open my $out_fh, '>', $file1;
												print {$out_fh} $doc2->toString;
												close($out_fh);
									}

								#loop to check for existance of env tag in the target file, if not updates the env value along with the value
									if (! $doc2->exists("/substitutions/application[\@name = '$abc']/file[\@path = '$path']/property[\@name = '$property']/env[\@name='$env']"))
										{
											  my($book1)=$doc2->findnodes("/substitutions/application[\@name = '$abc']/file[\@path = '$path']/property[\@name = '$property']");
											  my $fragment1 = $parser2->parse_balanced_chunk("$result\n");
											  $book1->appendChild($fragment1);
												open my $out_fh, '>', $file1;
												print {$out_fh} $doc2->toString;
												close($out_fh);
										}
								#loop for ideal case wherein all the required filepath,property,env tag exists but value is null, updates the null value

									else
									{
										my $new_items = ($doc2->findnodes("/substitutions/application[\@name = '$abc']/file[\@path = '$path']/property[\@name = '$property']/env[\@name='$env']"));
										foreach my $envname1($new_items->[0]->childNodes())
											{				

												$new_items->[0]->removeChild($envname1);
												$new_items->[0]->appendText("$result1");
												open my $out_fh, '>', $file1;
												print {$out_fh} $doc2->toString;
												close($out_fh);
											}

									
									
									}
							}
						}							
					}
				}
					
							$specificapp++;
			}

	}

sub usage 

{
	my $message = qq|	
	Usage: perl xmlparser.pl envname	
	Example: Perl xmlparser.pl PRD (in case of production)|;
	
	print $message;

	exit;
	
}
