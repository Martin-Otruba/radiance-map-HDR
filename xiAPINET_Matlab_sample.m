clear;
imaqreset;
NET.addAssembly('C:\XIMEA\API\xiAPI.NET.Framework.4.7.2\xiApi.NETX64.dll');
% NET.addAssembly('C:\XIMEA\API\x64\xiApi.NETX64.dll'); % Path to the xiApi.NET library in previous soft.package versions

myCam=xiApi.NET.xiCam;      % Initialize camera
NUM_OF_FRAMES = 1000;       % how many frames will be shown in preview

OpenDevice(myCam,0);
myCam.SetParam(xiApi.NET.PRM.EXPOSURE ,100000);

%% uncomment desired image format

% myCam.SetParam(xiApi.NET.PRM.IMAGE_DATA_FORMAT, xiApi.NET.IMG_FORMAT.RAW8);
% myCam.SetParam(xiApi.NET.PRM.IMAGE_DATA_FORMAT, xiApi.NET.IMG_FORMAT.RAW16);
% myCam.SetParam(xiApi.NET.PRM.IMAGE_DATA_FORMAT, xiApi.NET.IMG_FORMAT.MONO8);
% myCam.SetParam(xiApi.NET.PRM.IMAGE_DATA_FORMAT, xiApi.NET.IMG_FORMAT.MONO16);
 myCam.SetParam(xiApi.NET.PRM.IMAGE_DATA_FORMAT, xiApi.NET.IMG_FORMAT.RGB24);
% myCam.SetParam(xiApi.NET.PRM.IMAGE_DATA_FORMAT, xiApi.NET.IMG_FORMAT.RGB32);

%%
StartAcquisition(myCam);

showPreview(myCam, NUM_OF_FRAMES);

StopAcquisition(myCam);
CloseDevice(myCam);
delete(myCam);
clear myCam;




function []=showPreview(myCam, numOfFrames)
try
format = myCam.GetParam(xiApi.NET.PRM.IMAGE_DATA_FORMAT)

H=myCam.GetParam(xiApi.NET.PRM.HEIGHT);
W=myCam.GetParam(xiApi.NET.PRM.WIDTH);

figure;

%% Preview
if (format==5)||(format==0)
        disp('8-bit image format')
        myCam.SetParam(xiApi.NET.PRM.BUFFER_POLICY , xiApi.NET.BUFF_POLICY.SAFE);
        NetArray=NET.createArray('System.Byte',W*H);
        for id=1:numOfFrames
                GetImageByteArray(myCam,NetArray,1000);
                img=transpose(reshape(uint8(NetArray),W,H));
                
                % img is ready to process as MATLAB uint8 image matrix
                
                imshow(img);
                drawnow;
        end
        
elseif (format==1)||(format==6)
        disp('16-bit image format')
        myCam.SetParam(xiApi.NET.PRM.BUFFER_POLICY , xiApi.NET.BUFF_POLICY.SAFE);
        NetArray=NET.createArray('System.Byte',2*W*H);
        for id=1:numOfFrames
                GetImageByteArray(myCam,NetArray,1000);
                a=uint16(NetArray);
                img=zeros(H,W);
                k=1;
                for ii=1:H
                    for jj=1:W
                        img(ii,jj)=a(k+1)*256+a(k);
                        k=k+2;
                    end
                end
                
                % img is ready to process as MATLAB uint16 image matrix
                
                imshow(img,[]);
                drawnow;
        end
        
elseif (format==2)||(format==3)
        disp('Color image format')
        myCam.SetParam(xiApi.NET.PRM.BUFFER_POLICY , xiApi.NET.BUFF_POLICY.UNSAFE);
        bmap=GetImage(myCam,1000);
        BytesPerPixel=bmap.Format.BitsPerPixel/8;
        NetArray=NET.createArray('System.Byte',W*H*BytesPerPixel);
        img=zeros(H,W,3,'uint8');
        for id=1:numOfFrames
                bmap=GetImage(myCam,1000);    
                bmap.CopyPixels(NetArray,BytesPerPixel*W,0);  
                img_data=uint8(NetArray);
                img(:,:,1)=transpose(reshape(img_data(3:BytesPerPixel:end),W,H));
                img(:,:,2)=transpose(reshape(img_data(2:BytesPerPixel:end),W,H));
                img(:,:,3)=transpose(reshape(img_data(1:BytesPerPixel:end),W,H));
                
                % img is ready to process as MATLAB uint8 3-channel image matrix
                
                imshow(img);
                drawnow;
        end

else
    disp('Not supported image format')
end
    
catch ME
    disp(ME.message);  
end

end