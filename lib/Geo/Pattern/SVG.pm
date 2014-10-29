package Geo::Pattern::SVG;
use v5.20;
use Moose;
use experimental 'signatures';
use experimental 'postderef';

# if width or height is not Int, cocerce it to Int
has 'width'  => ( is => 'rw', isa => 'Int', default => 100 );
has 'height' => ( is => 'rw', isa => 'Int', default => 100 );

has 'svg_header' => ( is => 'ro', isa => 'Str', lazy_build => 1 );

sub _build_svg_header {
    my $self   = shift;
    my $width  = $self->width;
    my $height = $self->height;
    return
qq|<svg xmlns="http://www.w3.org/2000/svg" width="$width" height="$height">|;
}

has 'svg_closer' => ( is => 'ro', isa => 'Str', default => "</svg>" );

has 'svg_string' => ( is => 'rw', isa => 'Str', default => '' );

sub svg_string_append($self, $string) {
    $self->svg_string( $self->svg_string . $string );
}

sub to_s {
    my $self = shift;
    $self->svg_header . $self->svg_string . $self->svg_closer;
}

sub rect($self, $x, $y, $width, $height, %args) {
    my $extra = write_args(%args);
    my $rect =
      qq{<rect x="$x" y="$y" width="$width" height="$height" $extra />};
    $self->svg_string_append($rect);
}

sub circle($self, $cx, $cy, $r, %args) {
    my $extra  = write_args(%args);
    my $circle = qq{<circle cx="$cx" cy="$cy" r="$r" $extra />};
    $self->svg_string_append($rect);
}

sub path($self, $str, %args) {
    my $extra = write_args(%args);
    my $path  = qq{<path d="$str" $extra />};
    $self->svg_string_append($path);

}

sub polyline($self, $str, %args) {
    my $extra    = write_args(%args);
    my $polyline = qq{<polyline points="$str" $extra />};
    $self->svg_string_append($polyline);
}

sub group($self, $elements_aref, %args) {
    my $extra = write_args(%args);
    $self->svg_string_append(qq{<g $extra>});

    #elements.each {|e| eval e}
    eval $_ for @$elements_aref;
    $self->svg_string_append(qq{</g>});
}

sub write_args(%args) {
    my $str = '';
    while ( my ( $k, $v ) = each %args ) {
        if ( ref $v eq 'HASH' ) {
            $str .= qq|$key="|;
            while ( my ( $key, $vale ) = each %$v ) {
                $str . = "$k:$v;";
            }
            $str .= qq|" |;
        }
        else {
            $str .= qq{$k="$v" };
        }

    }

}

1;
