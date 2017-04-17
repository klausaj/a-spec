#fileID<ProcChoiceEquiv_al>

begin process InternalEquiv
where
   ServerFarm =
      web_request -> Server1 |~|
      web_request -> Server2;

   ServerFarm =
      web_request -> (Server1 |~| Server2);
end

begin process ExternalEquiv
where
   ServerFarm =
      web_request -> Server1 []
      web_request -> Server2 []
      ftp_request -> FTPServer;

   ServerFarm =
      web_request ->
         (Server1 |~| Server2) []
      ftp_request -> FTPServer;
end
