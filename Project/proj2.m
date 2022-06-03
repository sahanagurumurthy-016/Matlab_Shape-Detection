fontSize=20;
im=imread('C:\Users\Ajith\Pictures\im1.png');
imshow(im);

[rows,columns,noofColorBands]=size(im);
subplot(2,2,1);
imshow(im,[]);
title('Input Image','FontSize',fontSize);
%enlarge fig to full screen
set(gcf,'units','normalized','outerposition',[0 0 1 1]);
%give a name to title bar
set(gcf,'name','Shape Recognition Demo','numbertitle','off')



%if it's monochrome(indexed),convert it to a color.
if noofColorBands>1
    grayImage=im(:,:,2);
else
    grayImage=im;% if it's a already a grey scale image
end

subplot(2,2,2);
imshow(grayImage,[]);
title('Grayscale Image','FontSize',fontSize);




%{
%----------------------------------------
blue = im(:,:,1);
figure(2)
level = 0.37;
bw2 = imbinarize(blue,level);


subplot(2,2,1);imshow(bw2); title('Blue plane threshold')
%%Remove Noise
%%Fill any holes
fill = imfill(bw2, 'holes');
subplot(2,2,2); imshow(fill); title('Holes Filled');

%%Remove small objects
%clear = imclearborder(fill);
clear=bwareaopen(fill,300);
subplot(2,2,3); imshow(clear); title('Remove small objects');

%%Remove blobs that are smaller than 7 pixels across

se = strel('disk',7);
open = imopen(fill,se);
subplot(2,2,4); imshow(open); title('Remove small blobs')

%----------------------------------------------
%}
[labeledImage numberOfObjects]=bwlabel(grayImage);
blobMeasurements=regionprops(labeledImage,'Perimeter','Area','FilledArea','Solidity','Centroid','MajorAxisLength','MinorAxisLength');
%Get the outermost boundaries of the objects
filledImage=imfill(grayImage,'holes');
boundaries=bwboundaries(filledImage);

%collect some of the measurements into individual arrays.
perimeters=[blobMeasurements.Perimeter];
areas=[blobMeasurements.Area];
filledAreas=[blobMeasurements.FilledArea];
solidities=[blobMeasurements.Solidity];
Majoraxislength=[blobMeasurements.MajorAxisLength];
Minoraxislength=[blobMeasurements.MinorAxisLength];

circularities = (perimeters.^2)./(4*pi*filledAreas);

fprintf('#,Perimeter,     Area,     FilledArea, Solidity, Circularity, MajorAxisLength, MinorAxisLength\n');
for blobNumber=1 : numberOfObjects
    fprintf('%d,%9.3f,%11.3f,%11.3f,%8.3f,%11.3f,%9.3f,%9.3f\n',blobNumber,perimeters(blobNumber),areas(blobNumber),filledAreas(blobNumber),solidities(blobNumber),circularities(blobNumber),Majoraxislength(blobNumber),Minoraxislength(blobNumber));
end
for blobNumber=2 : numberOfObjects
    thisBoundary=boundaries{blobNumber};
    subplot(2,2,4);
    hold on;
    for k=1:blobNumber-1                  %display the previous boundaries in the blue
        thisBoundary=boundaries{k};
        plot(thisBoundary(:,2),thisBoundary(:,1),'b','LineWidth',3);
    end
    
    thisBoundary=boundaries{blobNumber};
    plot(thisBoundary(:,2),thisBoundary(:,1),'r','LineWidth',3);
    %subplot(2,2,4);
    
    
    %determine the shape
    
    if circularities(blobNumber)<=1.1
        message=sprintf('The circularitity of objects #%d is %.3f,\nso the object is a Circle\ndiameter:%.3f\nArea:%.3f',blobNumber,circularities(blobNumber),Majoraxislength(blobNumber),areas(blobNumber));
        shape='circle';
    elseif(1.10<=circularities(blobNumber)<=1.120)
        message=sprintf('The circularitity of objects #%d is %.3f,\nso the object is a square\nlength1:%.3f\nlength2:%.3f\nArea:%.3f',blobNumber,circularities(blobNumber),Majoraxislength(blobNumber),Minoraxislength(blobNumber),areas(blobNumber));
        shape='square';
   
    elseif 1.46<=circularities(blobNumber)<=1.48
        message=sprintf('The circularitity of objects #%d is %.3f,\nso the object is a Triangle\nlength1:%.3f\nlength2:%.3f\nArea:%.3f',blobNumber,circularities(blobNumber),Majoraxislength(blobNumber),Minoraxislength(blobNumber),areas(blobNumber));
        shape='triangle';
     elseif circularities(blobNumber)<2.0
        message=sprintf('The circularitity of objects #%d is %.3f,\nso the object is a Rectangle\nlength1:%.3f\nlength2:%.3f\nArea:%.3f',blobNumber,circularities(blobNumber),Majoraxislength(blobNumber),Minoraxislength(blobNumber),areas(blobNumber));
        shape='rectangle';
   
    else
        message=sprintf('The circularitity of objects #%d is %.3f,\nso the object is something else',blobNumber,circularities(blobNumber));
        shape='something else';
    end
    %overlayMessage=sprintf('Object #%d = %s\n circ=%.2f, s = %.2f',blobNumber,shape,circularities(blobNumber),solidities(blobNumber));
   % text(blobMeasurements(blobNumber).Centroid(1),blobMeasurements(blobNumber).Centroid(2),overlayMessage,'Color','r');
    button=questdlg(message,'Continue','Continue','Cancel','Continue');
    if strcmp(button,'Cancel')
       break;
    end
end
