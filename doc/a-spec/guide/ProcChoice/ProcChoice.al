#fileID<ProcChoice_al>

begin process InternalChoice
where
   ServerFarm =
      web_request -> (Server1 |~| Server2);
end

begin process ExternalChoice
where
   ServerFarm =
      web_request -> WebServer []
      ftp_request -> FTPServer;
end
