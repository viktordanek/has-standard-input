{
    inputs =
        {
            flake-utils.url = "github:numtide/flake-utils" ;
            nixpkgs.url = "github:NixOs/nixpkgs" ;
            strip-lib.url = "github:viktordanek/strip" ;
        } ;
    outputs =
        { flake-utils , nixpkgs , self , strip-lib , ... } :
            let
                fun =
                    system :
                    let
                        pkgs = import nixpkgs { inherit system; } ;
                        lib =
                            strip
                               ''
                                   [ -t 0 ] || [[ "$( ${ pkgs.coreutils }/bin/readlink /proc/self/fd/0 )" == pipe:* ]]
                               '' ;
                        strip = builtins.getAttr system ( builtins.getAttr "lib" strip-lib ) ;
                        in
                            {
                                lib = lib ;
                                checks.testLib =
                                    pkgs.stdenv.mkDerivation
                                        {
                                            name = "test-lib";
                                            builder = "${pkgs.bash}/bin/bash" ;
                                            args =
                                                [
                                                    "-c"
                                                    ''
                                                        observed='${ lib }' &&
                                                            expected='[ -t 0 ] || [[ "$( ${ pkgs.coreutils }/bin/readlink /proc/self/fd/0 )" == pipe:* ]]' &&
                                                            if [ "$observed" != "$expected" ]
                                                            then
                                                                    exit 1
                                                            else
                                                                ${ pkgs.coreutils }/bin/mkdir $out
                                                            fi
                                                    ''
                                                ] ;
                                        } ;
                            } ;
                in flake-utils.lib.eachDefaultSystem fun ;
}
