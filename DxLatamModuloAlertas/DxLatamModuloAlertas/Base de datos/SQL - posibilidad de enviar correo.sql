-- https://www.sqlshack.com/es/como-poder-configurar-la-base-de-datos-del-correo-en-sql-server/
sp_configure 'Database Mail XPs', 1;
GO
RECONFIGURE
GO

sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO
 
sp_configure 'Database Mail XPs', 1;
GO
RECONFIGURE
GO

--EXECUTE msdb.dbo.sysmail_delete_profileaccount_sp @profile_name = 'Notifications'
--EXECUTE msdb.dbo.sysmail_delete_principalprofile_sp @profile_name = 'Notifications'
--EXECUTE msdb.dbo.sysmail_delete_account_sp @account_name = 'Gmail'
--EXECUTE msdb.dbo.sysmail_delete_profile_sp @profile_name = 'Notifications'

--SELECT * FROM msdb.dbo.sysmail_event_log;

-- Create a Database Mail profile  
EXECUTE msdb.dbo.sysmail_add_profile_sp  
    @profile_name = 'Notifications',  
    @description = 'Profile used for sending outgoing notifications using Gmail.' ;  
GO

-- Grant access to the profile to the DBMailUsers role  
EXECUTE msdb.dbo.sysmail_add_principalprofile_sp  
    @profile_name = 'Notifications',  
    @principal_name = 'public',  
    @is_default = 1 ;
GO

-- Create a Database Mail account  
EXECUTE msdb.dbo.sysmail_add_account_sp  
    @account_name = 'Gmail',  
    @description = 'Mail account for sending outgoing notifications.',  
    @email_address = 'gabriela.reynoso@gmail.com',  
    @display_name = 'Automated Mailer',  
    @mailserver_name = 'smtp.gmail.com',
    @port = 465,
    @enable_ssl = 1,
    @username = 'gabriela.reynoso@gmail.com',
    @password = '***' ;  
GO

-- Add the account to the profile  
EXECUTE msdb.dbo.sysmail_add_profileaccount_sp  
    @profile_name = 'Notifications',  
    @account_name = 'Gmail',  
    @sequence_number =1 ;  
GO


EXEC msdb.dbo.sp_send_dbmail  
    @profile_name = 'Notifications',  
    @recipients = 'greynoso@dxlatam.com',  
    @body = 'The stored procedure finished successfully.',  
    @subject = 'Automated Success Message' ;