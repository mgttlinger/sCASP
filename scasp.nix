{ stdenv, lib, swi-prolog }:

stdenv.mkDerivation {
  pname = "sCASP";
  version = with builtins; head (match ".+version[(']+([^']+)[').]+.+" (readFile ./pack.pl));
  src = ./.;
  
  buildInputs = [ swi-prolog ];

  installPhase = ''
    mkdir -p $out/bin
    install -m755 scasp $out/bin/scasp
  '';
  meta = with lib; {
    description = "Top-down interpreter for ASP programs with Constraints";
    license = licenses.asl20;
    mainProgram = "scasp";
  };
}
