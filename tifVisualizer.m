function tifVisualizer(totalImage)
    %Visualizzazione .tif
    prompt='Do you want to visualize the modified tif? Type y/n: ';
    x=input(prompt,'s');

    if x=='y'
    cookedframes = mat2gray(totalImage);
    implay(cookedframes)
    end
end

