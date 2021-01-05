import os
import shutil
import pandas as pd

# Configure as required
input_classes_filename = '/Users/shailesh/XcodeProjects/SoundClassification/datasets/ESC-50/meta/esc50.csv'
sounds_directory = '/Users/shailesh/XcodeProjects/SoundClassification/datasets/ESC-50/audio/'
output_directory = '/Users/shailesh/XcodeProjects/SoundClassification/datasets/ESC-50/classes/'

classes_to_include = ['dog', 'rooster', 'pig', 'cow', 'frog', 'cat', 'hen', 'insects', 'sheep', 'crow']

# whether to use the whole dataset ESC-50 or lesser-restricted ESC-10 dataset
include_unlicensed = True

# Make output directory
try:
    os.makedirs(output_directory)
except OSError:
    if not os.path.isdir(output_directory):
        raise
        
# Make class directories within it
for class_name in classes_to_include:
    class_directory = output_directory + class_name + '/'
    try:
        os.makedirs(class_directory)
    except OSError:
        if not os.path.isdir(class_directory):
            raise

# Go through CSV to sort audio into class directories
classes_file = pd.read_csv(input_classes_filename, encoding='utf-8', header = 'infer')

# format: filename, fold, target, category, esc10, src_file, take
for line in classes_file.itertuples(index = False):
    if include_unlicensed or line[4] == True:
        file_class = line[3]

        if file_class in classes_to_include:
            file_name = line[0]
            file_src = sounds_directory + file_name
            file_dst = output_directory + file_class + '/' + file_name
            try:
                shutil.copy2(file_src, file_dst)
            except IOError:
                raise
            
