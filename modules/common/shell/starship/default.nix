{ lib, pkgs, ... }:

let
  bg = {
    sys = "mauve";
    usr = "sapphire";
    shl = "teal";
    dir = "peach";
    git = "pink";
    lng = "surface2";
    aws = "surface1";
    k8s = "surface0";
  };
  fg = {
    sys = "base";
    usr = "base";
    shl = "base";
    dir = "base";
    git = "base";
    lng = "base";
    aws = "base";
    k8s = "base";
  };
  style = {
    sys = "fg:${fg.sys} bg:${bg.sys}";
    usr = "fg:${fg.usr} bg:${bg.usr}";
    shl = "fg:${fg.shl} bg:${bg.shl}";
    dir = "fg:${fg.dir} bg:${bg.dir}";
    git = "fg:${fg.git} bg:${bg.git}";
    lng = "fg:${fg.lng} bg:${bg.lng}";
    aws = "fg:${fg.aws} bg:${bg.aws}";
    k8s = "fg:${fg.k8s} bg:${bg.k8s}";
  };
in {
  imports = [
    ./nerd-font-symbols.nix
  ];

  environment.systemPackages = [ pkgs.starship ];

  user.home-manager.programs.starship = {
    enable = true;

    catppuccin.enable = true;

    settings = {
      add_newline = true;

      # TODO: any other missing things

      format = lib.concatStrings [
        "$os"
        "$hostname"
        "[](fg:${bg.sys} bg:${bg.usr})"
        "[ 󰭕 ](${style.usr})$username" # TODO
        "[](fg:${bg.usr} bg:${bg.shl})"
        "[ 󰜗 ](${style.shl})$nix_shell"
        "[](fg:${bg.shl} bg:${bg.dir})"
        "[ 󰉖 ](${style.dir})$directory"
        "[](fg:${bg.dir} bg:${bg.git})"
        "$git_branch"
        "$git_status"
        "[](fg:${bg.git} bg:${bg.lng})"
        "$golang"
        "$nodejs"
        # TODO: package
        "[](fg:${bg.lng} bg:${bg.aws})"
        "$aws"
        "[](fg:${bg.aws} bg:${bg.k8s})"
        "$kubernetes"
        "[](fg:${bg.k8s})"
        "$line_break"
        "$character"
      ];
      os = {
        disabled = false;
        format = "[ $symbol ]($style)";
        style = style.sys;
      };
      hostname = {
        # ssh_only = false;
        format = "[$ssh_symbol$hostname ]($style)";
        style = style.sys;
      };
      username = {
        # show_always = true;
        style_user = style.usr;
        style_root = style.usr;
        format = "[$user ]($style)";
      };
      nix_shell = {
        style = style.shl;
        format = "[$name ]($style)";
      };
      directory = {
        style = style.dir;
        format = "[$path ($read_only )]($style)";
        truncation_length = 3;
        truncation_symbol = "…/";
      };
      git_branch = {
        style = style.git;
        format = "[[ $symbol $branch](${style.git})]($style)";
      };
      git_status = {
        style = style.git;
        format = "[[ ($all_status$ahead_behind )](${style.git})]($style)";
      };
      nodejs = {
        style = style.lng;
        format = "[[ $symbol( $version)](${style.lng})]($style)";
      };
      rust = {
        style = style.lng;
        format = "[[ $symbol( $version)](${style.lng})]($style)";
      };
      golang = {
        style = style.lng;
        format = "[[ $symbol( $version)](${style.lng})]($style)";
      };
      python = {
        style = style.lng;
        format = "[[ $symbol( $version)](${style.lng})]($style)";
      };
      aws = {
        style = style.aws;
        format = "[[ $symbol( $profile)( \($region\))(${style.aws})]($style)";
      };
      kubernetes = {
        disabled = false;
        style = style.k8s;
        format = "[[ $symbol( $context)( \($namespace\))](${style.k8s})]($style)";
      };
      # TODO: vars here
      character = {
        success_symbol = "[ 󰅂](bold fg:green)";
        error_symbol = "[ 󰅂](bold fg:red)";
        vimcmd_symbol = "[ 󰅁](bold fg:green)";
        vimcmd_replace_one_symbol = "[ 󰅁](bold fg:mauve)";
        vimcmd_replace_symbol = "[ 󰅁](bold fg:mauve)";
        vimcmd_visual_symbol = "[ 󰅁](bold fg:yellow)";
      };
    };
  };
}
