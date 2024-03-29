{ lib
, fetchFromGitHub
, python3Packages
, file
, less
, highlight
, w3m
, ranger
, testers
, imagePreviewSupport ? true
, neoVimSupport ? true
, improvedEncodingDetection ? true
, rightToLeftTextSupport ? false
}:

python3Packages.buildPythonApplication rec {
  pname = "ranger-git";
  version = "1.9.3.719.g136416c7";

  src = fetchFromGitHub {
    owner = "ranger";
    repo = "ranger";
    rev = "136416c7e2ecc27315fe2354ecadfe09202df7dd";
    sha256 = "09hvqnk8hvn2mv8m5w389q63wspyfksmwzkr7p8n70kfmfahlvlx";
  };

  LC_ALL = "en_US.UTF-8";

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];
  propagatedBuildInputs = [
    less
    file
  ] ++ lib.optionals imagePreviewSupport [ python3Packages.pillow ]
  ++ lib.optionals neoVimSupport [ python3Packages.pynvim ]
  ++ lib.optionals improvedEncodingDetection [ python3Packages.chardet ]
  ++ lib.optionals rightToLeftTextSupport [ python3Packages.python-bidi ];

  preConfigure = ''
    ${lib.optionalString (highlight != null) ''
      sed -i -e 's|^\s*highlight\b|${highlight}/bin/highlight|' \
        ranger/data/scope.sh
    ''}

    substituteInPlace ranger/__init__.py \
      --replace "DEFAULT_PAGER = 'less'" "DEFAULT_PAGER = '${lib.getBin less}/bin/less'"

    # give file previews out of the box
    substituteInPlace ranger/config/rc.conf \
      --replace /usr/share $out/share \
      --replace "#set preview_script ~/.config/ranger/scope.sh" "set preview_script $out/share/doc/ranger/config/scope.sh"
  '' + lib.optionalString imagePreviewSupport ''
    substituteInPlace ranger/ext/img_display.py \
      --replace /usr/lib/w3m ${w3m}/libexec/w3m

    # give image previews out of the box when building with w3m
    substituteInPlace ranger/config/rc.conf \
      --replace "set preview_images false" "set preview_images true"
  '';

  passthru.tests.version = testers.testVersion {
    package = ranger;
  };

  meta = with lib; {
    description = "File manager with minimalistic curses interface";
    homepage = "https://ranger.github.io/";
    license = licenses.gpl3Only;
    platforms = platforms.unix;
    maintainers = with maintainers; [ toonn magnetophon ];
    mainProgram = "ranger";
  };
}
