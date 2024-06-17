# number of keywords based on text length however dont force it to com[romise quality so radsej menej poriadnych ked nemam ake dat

# remove diacritics for improved compatibility - no need to text will have diacritics

# way to compare these outputs and determine whether files match

# possible error when selecting stopwords could actuallly be legit stemms

# certain words super rarely have extra meaning - dlouhy normally has no meaning but here it has

# consider hyphens at the end of line '-\n', hyphenated words not in czech merge lines if this is the case

# clean text more, remove tabs \r and other special characters

# debug mode, %not_keywords

# add sk cs en languages

# convert to lower case 

# ability to translate into other languages to combine similar works

# way to present results - export to a txt file?

# remove 2 letter stopwords too expensive


#!/bin/perl

use strict;
use warnings;
use utf8;
use open ':std', ':encoding(UTF-8)';

use List::Util qw(max);

if (@ARGV != 1) {
    die "To run enter:\nperl $0 <file_path>\n";
}

my $file_path = $ARGV[0];

unless (-e $file_path && -r $file_path) {
    die "Error: File '$file_path' does not exist or is not readable.\n";
}

use Ufal::MorphoDiTa;
my $tagger_file = "czech-morfflex2.0-pdtc1.0-220710/czech-morfflex2.0-pdtc1.0-220710.tagger";
my $tagger = Ufal::MorphoDiTa::Tagger::load($tagger_file) or die "Cannot load tagger from file '$tagger_file'\n";


my @stop_words = ( "aby", "ačkoli", "ahoj", "ale", "anebo", "ani", "aniž", "ano", "asi", "aspoň", "atd", "atp", "během", "bez", "beze", "blízko", "bohužel", "brzo", "bude", "budem", "budeme", "budes", "budeš", "budete", "budou", "budu", "byl", "byla", "byli", "bylo", "byly", "bys", "byt", "být", "čau", "chce", "chceme", "chceš", "chcete", "chci", "chtějí", "chtít", "chuti", "clanek", "článek", "clanku", "článku", "clanky", "články", "coz", "což", "čtrnáct", "čtyři", "dál", "dále", "daleko", "dalsi", "další", "děkovat", "děkujeme", "děkuji", "den", "deset", "devatenáct", "devět", "dnes", "dobrý", "docela", "dva", "dvacet", "dvanáct", "dvě", "hodně", "jak", "jakmile", "jako", "jakož", "jde", "jeden", "jedenáct", "jedna", "jedno", "jednou", "jedou", "jeho", "jehož", "jej", "jeji", "její", "jejich", "jelikož", "jemu", "jen", "jenom", "jenž", "jeste", "ještě", "jestli", "jestliže", "jež", "jich", "jím", "jimi", "jinak", "jine", "jiné", "jiný", "jiz", "již", "jíž", "jsem", "jses", "jseš", "jsi", "jsme", "jsou", "jste", "jšte", "kam", "každý", "kde", "kdo", "kdy", "kdyz", "když", "kolik", "kromě", "ktera", "která", "ktere", "které", "kteri", "kteři", "kteří", "kterou", "ktery", "který", "kvůli", "mají", "málo", "mám", "máme", "máš", "mate", "máte", "mezi", "mit", "mít", "mne", "mně", "mnou", "moc", "mohl", "mohou", "moje", "moji", "možná", "muj", "můj", "musí", "muze", "může", "načež", "nad", "nade", "nam", "nám", "námi", "napiste", "napište", "naproti", "nas", "nás", "náš", "naše", "nasi", "naši", "nebo", "nebyl", "nebyla", "nebyli", "nebyly", "nechť", "něco", "nedělá", "nedělají", "nedělám", "neděláme", "neděláš", "neděláte", "neg", "nějak", "nejsi", "nejsou", "někde", "někdo", "nemají", "nemáme", "nemáte", "neměl", "němu", "němuž", "neni", "není", "nestačí", "nevadí", "nez", "než", "nic", "nich", "ním", "nimi", "nove", "nové", "novy", "nový", "nula", "ode", "ona", "oni", "ono", "ony", "osm", "osmnáct", "pak", "patnáct", "pět", "pod", "podle", "pokud", "pořád", "potom", "pouze", "pozdě", "prave", "pravé", "práve", "pred", "před", "přede", "pres", "přes", "přese", "pri", "při", "přičemž", "pro", "proc", "proč", "prosím", "prostě", "proti", "proto", "protoze", "protože", "prvni", "první", "pta", "rovně", "sedm", "sedmnáct", "šest", "šestnáct", "sice", "skoro", "smějí", "smí", "snad", "spolu", "sta", "sté", "sto", "strana", "sve", "své", "svůj", "svych", "svých", "svym", "svým", "svymi", "svými", "tady", "tak", "take", "také", "takhle", "taky", "takze", "takže", "tam", "tamhle", "tamhleto", "tamto", "tato", "tebe", "tebou", "tedy", "těm", "tema", "téma", "těma", "těmu", "ten", "tento", "teto", "této", "tim", "tím", "timto", "tímto", "tipy", "tisíc", "tisíce", "tobě", "tohle", "toho", "tohoto", "tom", "tomto", "tomu", "tomuto", "toto", "třeba", "tři", "třináct", "trošku", "tuto", "tvá", "tvé", "tvoje", "tvůj", "tyto", "určitě", "vam", "vám", "vámi", "vas", "vás", "váš", "vase", "vaše", "vaši", "večer", "vedle", "vice", "více", "vlastně", "vsak", "však", "všechen", "všechno", "všichni", "vůbec", "vždy", "zač", "zatímco", "zda", "zde", "zpet", "zpět" );
my %stop_words = map { $_ => 1 } @stop_words;

sub weigh {
  my ( $keyword, $type ) = @_;

  my @allowed_word_types = ("AA","AC","AG","AM","AU",
                            "BN", "F%", "NN",
                            "VB","Vc","Ve","Vf","Vi","Vm","Vp","Vq","Vs","Vt");

  if ( length($keyword) < 3 || !grep( /^$type$/, @allowed_word_types ) || exists $stop_words{$keyword}) {
    return 0;
  }

  my $modifier = int(length($keyword) / 3) ;

  if (index($type, "N") != -1) { # noun
    return 10 + $modifier;
  } elsif (index($type, "F") != -1) { # foreign word
    return 9 + $modifier;
  } elsif (index($type, "V") != -1) { # verb
    return 8 + $modifier;
  } else { # adjective
    return 7 + $modifier;
  }
}

open my $fh, '<', $file_path or die "Can't open file: $_";

my %keywords = ();

while (my $line = <$fh>) {
  chomp($line);
  $line =~ s/["\$#@~!&*()\[\];.,:?^`\\\/“„—-]//g;
  $line =~ s/  / /g;

  my @words = split / /, $line;

  my $forms  = Ufal::MorphoDiTa::Forms->new(); $forms->push($_) for @words;
  my $lemmas = Ufal::MorphoDiTa::TaggedLemmas->new();
  
  $tagger->tag($forms, $lemmas);
  
  for my $i (0 .. $lemmas->size()-1) {
    my $lemma = $lemmas->get($i);
    my $stem = $lemma->{lemma};
    $stem =~ s/^.*?([a-zA-ZÁÄČĎÉĚÍĹĽŇÓÔÖŔŘŠŤÚŮÜÝŽáäčďéěíĺľňóôöŕřšťúůüýž]+).*$/$1/;

    my $word_type=substr($lemma->{tag},0,2);

    my $weight = weigh($stem, $word_type);
    unless ($weight == 0) {
      $keywords{$stem} += $weight;
    }

    # to get original word $forms->get($i)
  }
}

my $MINIMUM_PRIORITY = 0.3;

my @values = values %keywords;
my $max_value = max @values;
my $min_value = int($max_value * $MINIMUM_PRIORITY);


my %filtered = ();

while (my ($k, $v)=each %keywords) {
  unless ($v < $min_value) {
    $filtered{$k} = sprintf("%.5f", $v / $max_value);
  }
}

my @sorted_keys = sort { $filtered{$a} <=> $filtered{$b} } keys(%filtered);
my @sorted_vals = @filtered{@sorted_keys};

my $length = scalar(@sorted_keys);
for(my $i = 0; $i < $length; $i++) {
  print "[$sorted_vals[$i]] $sorted_keys[$i]\n";  
}
