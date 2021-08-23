FROM mcr.microsoft.com/dotnet/aspnet:5.0
COPY bin/Release/net5.0/ App/
COPY src/SETUPSERVER.INI App/
WORKDIR /App
ENTRYPOINT ["dotnet", "DxLatam_ValidaChkPoint.dll","SETUPSERVER.INI"]