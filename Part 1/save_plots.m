function save_plots(main_folder, extra_folders, file_name , save_formats , figure_id )

    arguments
        main_folder
        extra_folders
        file_name
        save_formats
        figure_id    = gcf
    end


    %  This way we could change the size of the figure before saving it 
    % fig = gcf() ; 
    % 
    % fig.Units = 'normalized' ;
    % fig.Position = [0 0 1 1]
    % 
    % default_size = [0.3536    0.4231    0.2917    0.3889] ;
    % medium_size = [0.1818   0.0787   0.5880     0.6898] ;
    % full_size = [0 0 1 1] ;


    % Save the plot using saveas
    for i = save_formats

        directoryPath = fullfile(main_folder,sprintf("format_%s",i),extra_folders) ;
        
        % Check if the directory exists, if not, create it
        if ~exist(directoryPath, 'dir')
            mkdir(directoryPath);
        end

        saveas(figure_id, fullfile(directoryPath,file_name) , i); % 'gcf' refers to the current figure
    end
end