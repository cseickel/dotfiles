FROM mcr.microsoft.com/dotnet/core/aspnet:3.1-alpine AS base
WORKDIR /app
RUN apk add icu-libs
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false
COPY ./rds-ca-2019-root.crt /usr/local/share/ca-certificates/rds-ca-2019-root.crt
RUN update-ca-certificates

FROM node:10.15-alpine AS client 
ARG skip_client_build=false 
WORKDIR /app 
COPY InvestmentsDatabase.Web/ClientApp . 
RUN [[ ${skip_client_build} = true ]] && echo "Skipping npm install" || npm install 
RUN [[ ${skip_client_build} = true ]] && mkdir dist || npm run-script build

FROM mcr.microsoft.com/dotnet/core/sdk:3.1-alpine AS build
WORKDIR /app
COPY . .
WORKDIR /app/InvestmentsDatabase.Web
RUN dotnet build "InvestmentsDatabase.Web.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "InvestmentsDatabase.Web.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
COPY --from=client /app/dist /app/ClientApp/dist
ENTRYPOINT ["dotnet", "InvestmentsDatabase.Web.dll"]
