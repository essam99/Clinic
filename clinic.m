rate = 0; 
arrivalArray = [];
serviceArray = [];
lambdaFlag = 0;
queue = [];
arrivalIndex = 1;
serviceIndex = 1;
endService = 0;
server = 0;
FEL = [];
FELchar = [];
FELindex = 1;
S = 0;
Sarray = [];
N = 0;
Narray = [];
F = 0;
Farray = [];
MQ = 0;
MQarray = [];
Tarray = [];

fprintf('Clinic System\n');
stime = input('Simulation time: ');
Fvalue = input('Mean proportion: ');
arrivalInput = input('Arrival process (D/M): ', 's');
serviceInput = input('Service process (M/U): ', 's');

if arrivalInput == 'd' || arrivalInput == 'D'
    rate = input('Arrival rate: ');
    for i = 0: (stime/rate)
        arrivalArray(i+1) = i * rate;
    end
else
    if arrivalInput == 'm' || arrivalInput == 'M'
        lambda = input('Lambda: ');
        lambdaFlag = 1;
        i = 1;
        while i > 0
            u = rand();
            %y = round(-log(u/lambda));
            y = ceil((-1/lambda)*log(1-u));
            if i == 1
                    arrivalArray(i) = 0; 
            else
                if ( y + arrivalArray(i-1) <= stime )
                    arrivalArray(i) = arrivalArray(i-1) + y; 
                else
                    break;
                end
            end
            i = i + 1;
        end
    end
end
size = length(arrivalArray);
if serviceInput == 'u' || serviceInput == 'U'
    maxService = input('Maximum service time: ');
    serviceArray = unidrnd(maxService, 1, size);
else
    if serviceInput == 'm' || serviceInput == 'M'
        if (lambdaFlag == 0)
            lambda = input('Lambda: ');
        end
        for i = 1: size
            u = rand();
            %y = round(-log(u/lambda));
            y = ceil((-1/lambda)*log(1-u));            
            serviceArray(i) =  y;
        end
    end
end

fprintf('\nArrivals: '); 
disp(arrivalArray);
fprintf('Services: ');
disp(serviceArray);

for time = 0 : stime
    MQmax = 0;
    if(arrivalIndex <= size && arrivalArray(arrivalIndex) == time)
        fprintf('At %i, patient %i arrived\n', arrivalArray(arrivalIndex), arrivalIndex);
        for i = serviceIndex: arrivalIndex
            if(arrivalIndex - serviceIndex == 0)
                queue = [queue [time; arrivalIndex]];
            else
                if(i == serviceIndex) 
                    if (endService > time)
                        queue= [queue [time; i]];
                    end
                else
                    queue= [queue [time; i]];
                end
            end
        end
        
            if(arrivalIndex - serviceIndex >= 1 && endService > time)
                MQmax = arrivalIndex - serviceIndex;
            end

        arrivalIndex = arrivalIndex + 1;
        if(arrivalIndex < size)
            FEL = [FEL [time;  arrivalArray(arrivalIndex); arrivalIndex]];
            FELchar(FELindex) = 'A';
            FELindex = FELindex + 1;
        end
    end
    if (server == 0 && serviceIndex < arrivalIndex)
        fprintf('At %i, patient %i entered\n',  time, serviceIndex);
        server = 1;
        endService = time + serviceArray(serviceIndex);
        FEL = [FEL [time;  endService; serviceIndex]];
        FELchar(FELindex) = 'D';
        FELindex = FELindex + 1;
    end
    if(serviceIndex <= size && endService == time && server == 1)
        fprintf('At %i, patient %i leaved\n', time, serviceIndex);
        server = 0;
        serviceIndex = serviceIndex + 1;
        if (serviceIndex < arrivalIndex)
            fprintf('At %i, patient %i entered\n', time, serviceIndex);
            server = 1;
            endService = time + serviceArray(serviceIndex);
            FEL = [FEL [time;  endService; serviceIndex]];
            FELchar(FELindex) = 'D';
            FELindex = FELindex + 1;
        end
        S = S + serviceArray(serviceIndex-1);
        N = N + 1;
        if(time - arrivalArray(serviceIndex - 1) >= Fvalue)
           F = F + 1; 
        end   
    end
    if(MQmax > MQ)
       MQ = MQmax; 
    end
    if(time > 0)
        Sarray(time) = S; 
        Narray(time) = N;
        Farray(time) = F;
        MQarray(time) = MQ;
        Tarray(time) = time;
    end
end

fprintf('Checkout queue:\n'); 
disp(queue);
fprintf('FEL:\n'); 
fprintf('     ');
for i = 1: length(FELchar)
    fprintf('%c     ',FELchar(i));
end
fprintf('\n');
disp(FEL);
Tarray = [ 0, Tarray ];
Sarray = [ 0, Sarray ];
fprintf('S: \n');
disp(Tarray);
disp(Sarray);
Narray = [ 0, Narray ];
fprintf('N: \n');
disp(Tarray);
disp(Narray);
Farray = [ 0, Farray ];
fprintf('F: \n');
disp(Tarray);
disp(Farray);
MQarray = [ 0, MQarray ];
fprintf('MQ: \n');
disp(Tarray);
disp(MQarray);
%S, N, F, MQ
plot(Tarray, Sarray, Tarray, Narray, Tarray, Farray, Tarray, MQarray)
figure();
%checkout queue
plot(queue(1,:), queue(2,:))