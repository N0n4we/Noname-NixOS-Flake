{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    (python312.withPackages (python-pkgs:
      with python-pkgs; [
        requests
        numpy
        pandas
        pillow
        prompt-toolkit
        pyperclip
        moviepy
        uvicorn
        fastapi
        websockets
        faker
      ]))
    uv
  ];
}
