push @extra_pdflatex_options, '-synctex=1' ;
$pdf_mode=1;

# Glossaries support
add_cus_dep('glo', 'gls', 0, 'run_makeglossaries');
add_cus_dep('acn', 'acr', 0, 'run_makeglossaries');
sub run_makeglossaries {
    my ($base_name, $path) = fileparse( $$Psource );
    my @args = ( "-q", "-d", $path, $base_name );
    if ($silent) { unshift @args, "-q"; }
    return system "makeglossaries", @args;
}
