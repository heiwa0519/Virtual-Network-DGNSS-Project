To start this client, please firstly read the client manual

The executable file for Linux exists in the 'bin' folder
Example command:
```
sudo ./WADGNSS_Client_Linux /dev/ttyACM0 1 192.168.1.107 3636
```
The executable file for Windows exists in the 'app' folder.
You would have to input arguments for com port, option, Server host, port in Run_Client.bat file.
Then double Run_Client.bat to run WADGNSS_Client.exe.

The source code build with CMake. If you want to compile the source code in Windows, for instance, in VS 2019, please open 'WADGNSS_Client
' by CMake
