clear;
% 1.�������ݼ��ĵ��������ݴ���400��ͼ��һ��40�ˣ�һ��10�ţ�
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
reshaped_faces=[];
for i=1:40    
    for j=1:10       
        if(i<10)
           a=imread(strcat('F:\matlabProject\PCAla2\face\AR_Gray_50by40\AR00',num2str(i),'-',num2str(j),'.tif'));     
        else
            a=imread(strcat('F:\matlabProject\PCAla2\face\AR_Gray_50by40\AR0',num2str(i),'-',num2str(j),'.tif'));  
        end          
        b = reshape(a,2000,1);
        b=double(b);        
        reshaped_faces=[reshaped_faces, b];  
    end
end

% ȡ��ǰ30%��Ϊ�������ݣ�ʣ��70%��Ϊѵ������
test_data_index = [];
train_data_index = [];
for i=0:39
    test_data_index = [test_data_index 10*i+1:10*i+3];
    train_data_index = [train_data_index 10*i+4:10*(i+1)];
end

% %�����飨������ѵ���������䣬ȡ��ͼ���б仯��
% % ȡ��ǰ70%��Ϊѵ�����ݣ�ʣ��30%��Ϊ��������
% test_data_index = [];
% train_data_index = [];
% for i=0:39
%     train_data_index = [train_data_index 10*i+1:10*i+7];
%     test_data_index = [test_data_index 10*i+8:10*(i+1)];
% end

train_data = reshaped_faces(:,train_data_index);
test_data = reshaped_faces(:, test_data_index);


%����չʾ���ܺ�ĳЩѵ��ͼƬ ������
%show_faces(train_data); 

% 2.ͼ�����ֵ�����Ļ�
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ��ƽ����
mean_face = mean(train_data,2);
%waitfor(show_face(mean_face)); %ƽ����չʾ��������

% ���Ļ�
centered_face = (train_data - mean_face);
%����չʾ���Ļ���ĳЩѵ��ͼƬ ������
%waitfor(show_faces(centered_face));

% 3.��Э�����������ֵ����������������
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Э�������
cov_matrix = centered_face * centered_face';
[eigen_vectors, dianogol_matrix] = eig(cov_matrix);

% �ӶԽǾ����ȡ����ֵ
eigen_values = diag(dianogol_matrix);

% ������ֵ���������дӴ�С����
[sorted_eigen_values, index] = sort(eigen_values, 'descend'); 

% ��ȡ��������ֵ��Ӧ����������
sorted_eigen_vectors = eigen_vectors(:, index);

% ������(���У�
all_eigen_faces = sorted_eigen_vectors;

%����չʾĳЩ������ ������
waitfor(show_faces(all_eigen_faces));

% 4.�����ع�
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ȡ����һ���˵������������ؽ�
single_face = centered_face(:,1);

index = 1;
for dimensionality=20:20:160

    % ȡ����Ӧ������������ǰn������������������ع�������
    eigen_faces = all_eigen_faces(:,1:dimensionality);

    % �ؽ���������ʾ
        rebuild_face = eigen_faces * (eigen_faces' * single_face) + mean_face;
        subplot(2, 4, index); %��������
        index = index + 1;
        fig = show_face(rebuild_face);
        title(sprintf("dimensionality=%d", dimensionality));    
        if (dimensionality == 160)
            waitfor(fig);
        end
end

% 5.����ʶ��
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

index = 1;       
Y = [];
% KNN
for k=1:6

    for i=10:10:160
    % ȡ����Ӧ����������
   eigen_faces = all_eigen_faces(:,1:i);
    % ���ԡ�ѵ�����ݽ�ά
    projected_train_data = eigen_faces' * (train_data - mean_face);
    projected_test_data = eigen_faces' * (test_data - mean_face);
        % ���ڱ�����С��k��ֵ�ľ���
        % ���ڱ�����Сk��ֵ��Ӧ���˱�ǩ�ľ���
        minimun_k_values = zeros(k,1);
        label_of_minimun_k_values = zeros(k,1);

        % ������������
        test_face_number = size(projected_test_data, 2);

        % ʶ����ȷ����
        correct_predict_number = 0;

        % ����ÿһ������������
        for each_test_face_index = 1:test_face_number

            each_test_face = projected_test_data(:,each_test_face_index);

            % �Ȱ�k��ֵ�����������ڵ����з����ж�
            for each_train_face_index = 1:k
                minimun_k_values(each_train_face_index,1) = norm(each_test_face - projected_train_data(:,each_train_face_index));
                label_of_minimun_k_values(each_train_face_index,1) = floor((train_data_index(1,each_train_face_index) - 1) / 10) + 1;
            end

            % �ҳ�k��ֵ�����ֵ�����±�
            [max_value, index_of_max_value] = max(minimun_k_values);

            % ������ʣ��ÿһ����֪�����ľ���
            for each_train_face_index = k+1:size(projected_train_data,2)

                % �������
                distance = norm(each_test_face - projected_train_data(:,each_train_face_index));

                % ������С�ľ���͸��¾���ͱ�ǩ
                if (distance < max_value)
                    minimun_k_values(index_of_max_value,1) = distance;
                    label_of_minimun_k_values(index_of_max_value,1) = floor((train_data_index(1,each_train_face_index) - 1) / 10) + 1;
                    [max_value, index_of_max_value] = max(minimun_k_values);
                end
            end

            % ���յõ�������С��k��ֵ�Լ���Ӧ�ı�ǩ
            % ȡ�����ִ�������ֵ��ΪԤ���������ǩ
            predict_label = mode(label_of_minimun_k_values);
            real_label = floor((test_data_index(1,each_test_face_index) - 1) / 10)+1;

            if (predict_label == real_label)
                %fprintf("Ԥ��ֵ��%d��ʵ��ֵ:%d����ȷ\n",predict_label,real_label);
                correct_predict_number = correct_predict_number + 1;
            else
                %fprintf("Ԥ��ֵ��%d��ʵ��ֵ:%d������\n",predict_label,real_label);
            end
        end
        % ����ʶ����
        correct_rate = correct_predict_number/test_face_number;

        Y = [Y correct_rate];

        fprintf("k=%d��i=%d���ܲ���������%d����ȷ��:%d����ȷ�ʣ�%1f\n", k, i,test_face_number,correct_predict_number,correct_rate);
    end
end
% ��ͬkֵ��ͬά���µ�����ʶ���ʼ�ƽ��ʶ����
Y = reshape(Y,k,16);
waitfor(waterfall(Y));
avg_correct_rate=mean(Y);
waitfor(plot(avg_correct_rate));

% 6.�������ݶ���ά���ӻ������ƹ㵽��ͬ���ݼ���
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i=[2 3]

    % ȡ����Ӧ����������
    eigen_faces = all_eigen_faces(:,1:i);

    % ͶӰ
    projected_test_data = eigen_faces' * (test_data - mean_face);

    color = [];
    for j=1:120
        color = [color floor((j-1)/4)*5];
    end

    % ��ʾ
    if (i == 2)
        waitfor(scatter(projected_test_data(1, :), projected_test_data(2, :), [], color));
    else
        waitfor(scatter3(projected_test_data(1, :), projected_test_data(2, :), projected_test_data(3, :), [], color));
    end

end

%���ú�������
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ������������ʾ��
function fig = show_face(vector)
    fig = imshow(mat2gray(reshape(vector, [50, 40])));
end

% ��ʾ������ĳЩ��
function fig = show_faces(eigen_vectors)
    count = 1;
    index_of_image_to_show = [1,5,10,15,20,30,50,70,100,150];
    for i=index_of_image_to_show
        subplot(2,5,count);
        fig = show_face(eigen_vectors(:, i));
        title(sprintf("i=%d", i));
        count = count + 1;
    end
end