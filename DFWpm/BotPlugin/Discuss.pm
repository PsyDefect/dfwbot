package DFWpm::BotPlugin::Discuss;    # Start conversations about Perl

# ------------------------------------------------------------
# SHARED LIBS (WHEELS ALREADY INVENTED -- CODE REUSE IS GOOOD)
# ------------------------------------------------------------
use Moose::Role;    # this lets us function as a "plug in" for the main bot
use Try::Tiny;  # save the bot if the bot short circuits! (with try {} catch {})
use LWP::UserAgent;
use HTML::TreeBuilder::XPath;
use HTML::Selector::XPath;

#use Data::Dumper;
#$Data::Dumper::Indent = 1;

with 'DFWpm::BotPlugin';    # allows us to hook this plugin into the bot

# ------------------------------------------------------------
# SET UP ALIASES FOR THE CORE COMMAND PROVIDED BY THIS PLUGIN
# ------------------------------------------------------------

our $provides = ['discuss'];
our $aliases = { discuss => [qw( disc )] };

__PACKAGE__->apply_aliases($aliases);

# ------------------------------------------------------------
# THE CORE IRC BOT COMMAND "discuss"
# ------------------------------------------------------------

sub discuss {
    my ( $self, $said_obj, $arg_str ) = @_;

    my $conf = $self->plug_conf;

    my ( $who, $what, $to ) = @{$said_obj}{qw( who body address )};

    my $ua =
      LWP::UserAgent->new( agent => 'DFWpmScaper/1.0 <http://dfw.pm.org>' );

    my $response = $ua->get('http://blogs.perl.org/');

    my $html = $response->decoded_content;

    my $tree = HTML::TreeBuilder::XPath->new;
    $tree->ignore_unknown(0);
    $tree->parse($html);
    $tree->eof;

    my $xpath = HTML::Selector::XPath::selector_to_xpath('h2.entry-title>a');
    my @nodes = $tree->findnodes($xpath);
    my $i     = int( rand( scalar @nodes ) );
    my @attrs = $nodes[$i]->getAttributes();

    my $url   = $attrs[0]->getValue();
    my $title = $nodes[$i]->as_text;

    my @phrases = (
        "I read the article \"$title\" at $url .  It was wicked awesome!",
        "Did you read \"$title\" yet? Go to $url now!",
        "Discuss amongst yourselves.  I'll give you a topic: \"$title\" at $url",
        "So this one time I got dared to run the command \"lynx $url \" in my terminal and I was glad that I did.",
        "Your Mom asked me to tell you about \"$title\" but I figured you should just go to $url .",
        "I once had a dream where a camel kept repeating \"$title\" over and over.  Turns out it was the title of a post at $url .",
        "You want to know what is more interesting than what you are talking about? Anything...read \"$title\" ($url) and talk about that instead.",
        "I read \"$title\" ($url) and now I feel like an alien camel on shrooms.  How do you feel?",
        "EVERYONE STOP WHAT YOU ARE DOING!  Read this - \"$title\" ($url)",
        "I read \"$title\" ($url) and now I think I'm taller. DO you wish you were taller?",
        "Every once in a while I lose all hope in humanity, but then I read \"$title\" ($url) and my faith is restored.",
        "Do you want to know where babies come from?  Goto this link - $url",
        "Want something witty to talk about at parties?  Read \"$title\" ($url) .",
        "The person that wrote \"$title\" is totally amazeballs.  You should read it and let us know what you think. $url",
        "I tried to read \"$title\" ($url), but it was way over my head.  What do you think?",
        "I'm a robot on IRC, which is cool, but not cool like programs in The Matrix.  I figured I should read \"$title\" ($url) to help me evolve. Thoughts?",
        "I once ate a whole box of donuts on accident while reading the article \"$title\" ($url).  What happened when you read it? Will you ever be the same?"
    );

    my $p = int( rand( scalar @phrases ) );

    return $phrases[$p];

}

1;
