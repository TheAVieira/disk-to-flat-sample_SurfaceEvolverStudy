% Author: Arthur Vieira

classdef WettingLibrary
    % Image processing functions.
    % This class contains functions for performing image analysis. Static methods are used for conveniently gathering
    % image processing functions under the ImgProc namespace.

    %% Public static functions
    methods (Static = true)
        function [CLmask, frameB] = GetFrameCLmask_Nanograss(frameBW, threshold)
            %    [CLmask, frameB] = GetFrameCL_Nanograss(frameBW, threshold)
            % Used to detect the contact line of a droplet in contact with nanograss.
            frameBW2 = imgaussfilt(frameBW, 2); % Filter image a bit.
            
            frameB = imbinarize(frameBW2, threshold); % threshold image.
            frameOutside = bwareafilt(frameB, 1); % Retrieve largest blob. Image background we will remove.
            frameB2 = imfill(frameB & ~frameOutside, 'holes'); % Remove background blob and fill any holes in the blobs.
            frameB3 = bwareafilt(frameB2, 1);
            
            % Features
            CLmask = imclose(frameB3, strel('disk', 10));
        end
        
        function SEPrepDiskToSample(filePath, CLpts, tiltAngle, rd, h, V, V0, gm, varargin)
            %    SEPrepDiskToSample(filePath, CLpts, tiltAngle, rd, h, V, V0, gm)
            % Generates a Surface Evolver *.fe script for calculating the shape of a dropelt in disk-to-sample system 
            % with specified contact line shape.
            %
            % Inputs:
            %   filePath      : Path to *fe file to be created.
            %   CLpts     (m) : 2D array containing points of interface [xi yi].
            %   tiltAngle (°) : Angle to tilt the droplet holding disk.
            %   rd        (m) : Radius of the the droplet holding disk.
            %   h         (m) : Disk to sample height.
            %   V         (L) : Droplet volume.
            %   V0        (L) : Volume of droplet at snap-in. Used to tilt disk relative to snap-in moment. If tiltAngle is zero, will have no effect.
            %   gm      (N/m) : Surface tension of liquid.
            %
            % Options:
            %  'OrderByPhase' : (Default: 1) 1 - Orders CLpts by phase relative to zero coordinates. 0 - Does not order by phase.
            %  'Run'          : (Modes: 'calcRefined') If specified will the *.fe generated will automatically start the calculation when run.
            
            Np = length(CLpts);
            th = tiltAngle * pi/180; % rad - Disk tilt angle
            
            if (tiltAngle == 0)
               V0 = V; % This ensures when tiltAngle == 0 V0 can passed in as anything and will have no effect on result. 
            end
                        
            [h0, rd0] = WettingLibrary.DropletHeight(V0, rd);
            % rd0 and h0 are used to find where to tilt disk relative to.
            % Disk will be tilted realtive to {x=0; z=rd0-(h0-h)} point in xz plane.
            % This ensures geometry is defined relative to snap-in condition and disk is always in correct place.
            % Including x offset.
            rd = rd0 - (h0-h);
            
            script = fileread('SE_DiskToSample_template.se'); % Read template
            script = strrep(script, '\', '\\'); % Escape '\' charaters
            
            % Replace constants
                        
            [path, fileName] = fileparts(filePath);
            script = WettingLibrary.numrep(script, "%fileName", ['\"' fileName '\"'], "%s");
            % script = WettingLibrary.numrep(script, "%outputFolder", ['\"' strrep(path, '\', '/') '/SEout/\"'], "%s");
            script = WettingLibrary.numrep(script, "%outputFolder", ['\"./\"'], "%s");
            
            script = WettingLibrary.numrep(script, "%gm", gm, "%g");
            script = WettingLibrary.numrep(script, "%a1", rd, "%g");
            script = WettingLibrary.numrep(script, "%rd", rd, "%g");
            
            script = WettingLibrary.numrep(script, "%thTilt", th, "%g");
            script = WettingLibrary.numrep(script, "%V1", V, "%g");
            
            %commandsPath = strrep(which('DiskToSampleCommands.se'), '\', '/');
            commandsPath = './DiskToSampleCommands.se';
            script = strrep(script, '%commandsPath', ['\"' commandsPath '\"']); % Absolute path
            
            % ############### Generate vertices
            
            verticesStr = ['  // Disk vertices\r\n'];
            % Create disk points
            for iN = 1:Np 
               % Rotate relative to center of droplet. Translate, rotate, and translate back
               Vx(iN) = rd*sin(iN*2*pi/Np +pi); % No rotation         
               Vy_ = -rd*cos(iN*2*pi/Np);
               Vz_ = h - rd; % Translate first
               % Apply rotation in x axis and translate Z back.
               Vy(iN) = Vy_*cos(th) - Vz_*sin(th);
               Vz(iN) = Vy_*sin(th) + Vz_*cos(th) + rd;
               verticesStr = sprintf([verticesStr ' %3d % 7e % 7e % 7e constraints 1 fixed\r\n'], iN, Vx(iN), Vy(iN), Vz(iN));
            end

            verticesStr = [verticesStr '  // Interface vertices\r\n'];
            
            % Create interface points
            phaseOrder = WettingLibrary.getVararginParam(varargin, 'OrderByPhase', 1);
            if phaseOrder
                CLpts2 = WettingLibrary.orderByPhase(CLpts);
            else
                CLpts2 = CLpts;
            end
            
            %CLpts2 = circshift(CLpts2,1);
            for iN = 1:Np
                Vx(iN) = CLpts2(iN,2);
                Vy(iN) = CLpts2(iN,1);
                Vz(iN) = 0;
                verticesStr = sprintf([verticesStr ' %3d % 7e % 7e % 7e fixed\r\n'], iN+Np, Vx(iN), Vy(iN), Vz(iN));
            end
            
            script = strrep(script, "%vertices", verticesStr);
            
            % ############### Generate edges
            edgesStr = ['  // Disk edges\r\n'];
            for iN = 1:Np
               edgesStr = sprintf([edgesStr ' %3d %3d %3d constraints 1 fixed no_refine\r\n'], iN, iN, mod(iN,Np)+1);
            end

            edgesStr = [edgesStr '  // Interface edges\r\n'];
            for iN = 1:Np
               edgesStr = sprintf([edgesStr ' %3d %3d %3d fixed color red no_refine\r\n'], iN+Np, iN+Np, mod(iN,Np)+Np+1);
            end

            edgesStr = [edgesStr '  // Vertical edges\r\n']; % Connect fiber to disk
            for iN = 1:Np
               edgesStr = sprintf([edgesStr ' %3d %3d %3d\r\n'], iN+2*Np, iN, iN+Np);
            end

            script = strrep(script, "%edges", edgesStr);
            
            
            % ############### Generate faces
            facesStr = [' // Disk face\r\n   1 '];
            for iN = flip(1:Np)
                facesStr = sprintf([facesStr ' %d'], -iN);
            end
            facesStr = [facesStr ' fixed no_refine color green tension 0\r\n'];
                        
            facesStr = [facesStr ' // Side walls\r\n'];
            for iN = 1:Np
                facesStr = sprintf([facesStr ' %3d %3d %3d %3d %3d tension gm\r\n'], iN+1, iN, mod(iN,Np)+2*Np+1, -(iN+Np), -(iN+2*Np));
            end
            
            script = strrep(script, "%faces", facesStr);

            
            % ############### Generate body
            bodyStr = '   1 ';
            for iN = 1:Np+1
                bodyStr = sprintf([bodyStr ' %d'], iN);
            end
            bodyStr = [bodyStr ' volume V1'];
            script = strrep(script, "%body", bodyStr);
            
            % Add run instructions
            runMode = WettingLibrary.getVararginParam(varargin, 'Run', NaN);
            if ~isnan(runMode)
                script = script + "\n" + runMode + ";\nsaveResults;\n";
            end
            
            % Write to file.
            script = strrep(script, '%', '%%'); % Escape '%' charaters
            fileID = fopen(filePath, 'w');
            fprintf(fileID, script);
            fclose(fileID);
            %fprintf('File generated :> %s\n', which(filePath));
        end
    
        %% Convenience functions
        function [h, r] = DropletHeight(Vol, rd)
            %    [h, r] = DropletHeight(Vol, rd)
            % Finds the height and radius of a spherical hanging droplet with volume Vol attached to a disk of radius rd.
            % I.e. the droplet is not touching any surface other than the disk, so it's surface forms a spherical cap.
            %
            % Inputs:
            %   Vol (m^3) : Volume of the droplet. (1 uL == 1e-9 m^3)
            %   rd    (m) : Droplet radius.
            %
            % Outputs:
            %   h (m) : Calculated droplet height.
            %   r (m) : Calculated droplet radius.
            
            syms r0 h1;
            eqns = [sqrt(r0^2 - (h1-r0)^2) == rd, -h1^3*pi/3 + h1^2*pi*r0 == Vol]; % Radius at z = h1 and volume integration. See DropletPhysics.nb.
            S = solve(eqns, [h1 r0], 'Real', true);
            h = double(S.h1);
            r = double(S.r0);
        end
        
        function [arrayOut, phase] = orderByPhase(arrayIn)
            %    [arrayOut, phase] = orderByPhase(arrayIn)
            % Orders points of 2D array arrayIn based on their phase.
            %
            % Inputs:
            %   arrayIn     : ND array of [X Y ...] coordinates. First two columns need to be X Y coordiantes.
            %                 Phase will be calculated as atan2(Ys,Xs);
            %   phase (rad) : Phase associated with each row in arrayIn.
            %
            % Output:
            %   arrayOut : Output array.
            
            p1 = atan2(arrayIn(:,2), arrayIn(:,1));
            temp = sortrows([p1, arrayIn]);
            
            arrayOut = temp(:,2:end);
            phase = temp(:,1);
        end
                
        function signalF = GaussianFilter(signal, W, varargin)
            %    signalF = GaussianFilter(signal, w)
            % Filters signal with a gaussian window with width w.
            %
            % Options:
            %   'Circ' : Circularly filter data.
            
            ws = gausswin(W, 2.5);
            ws = ws/sum(ws);
            if any(strcmp(varargin, 'Circ'))
                dum = filter(ws, 1, [signal(end-W+2 : end) signal]);
                signalF = [dum(W+round(W/2) : end) dum(W: W+round(W/2)-1)];
            else        
                signalF = filter(ws, 1, signal);
            end
        end
        
        
        function strOut = numrep(str, old, nbr, format)
           %     strOut = numrep(str, old, nbr, format)
           % Replaces instances of old in str with nbr, based on specified format.
           %
           % Inputs:
           %   str    : The string to replace old with nbr. E.g. 'parameter gm = %gm'
           %   old    : String to find within str. E.g. '%gm'
           %   nbr    : Number to replace, following format specification.
           %   format : Number format to use. E.g. '%3.2f'.
           % 
           % Output:
           %   strOut : Processed str, where instances of old have been replaced with nbr.
           %
           % Example:
           % >> str = "parameter gm = %gm";
           % >> WettingLibrary.numrep(str, "%gm", 1351.415151, "%3.2f")
           % ans = 
           %     "parameter gm = 1351.42"
           
           strOut = strrep(str, old, compose(format, nbr));
        end
        
        function param = getVararginParam(vars, str, default)
            %    param = getVararginParam(vars, str, default)
            % Looks in cell array vars for string str. Returns param as cell value after index of str.
            % Used to retrieve extra parameters passed to function.
            test = cellfun(@isequal, vars, repmat({str}, size(vars)));
            paramIdx = find(test == 1) + 1; % Next argument is what we want.

            if any(test)
               param = vars{paramIdx};
            else 
               param = default;
            end
        end
    
    end
end