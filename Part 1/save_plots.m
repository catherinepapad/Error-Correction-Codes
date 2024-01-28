function save_plots(main_folder, extra_folders, file_name , save_formats , figure_id )

    arguments
        main_folder
        extra_folders
        file_name
        save_formats
        figure_id    = gcf
    end

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