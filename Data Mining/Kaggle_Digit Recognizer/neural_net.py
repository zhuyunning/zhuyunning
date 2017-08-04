# -*- coding: utf-8 -*-
"""
Created on Mon Apr 17 16:49:39 2017

@author: patri
"""

import h2o
from h2o.estimators.deeplearning import H2ODeepLearningEstimator
from h2o.grid.grid_search import H2OGridSearch


h2o.init(max_mem_size = '800m')
path = "C:\\Users\\patri\\Documents\\GW\\Spring17\\Data Mining\\Project\\train_mod.csv"
col_types = {'label': 'enum'}
frame = h2o.import_file(path=path, col_types=col_types)

y = 'label'
X = [var for var in frame.columns if var not in ['label']]

training, validation = frame.split_frame([0.7])
training[y] = training[y].asfactor()
validation[y] = validation[y].asfactor()

# define random grid search parameters
hyper_parameters = {'hidden':[[784], [1176], [784, 392], [392, 784]],
                    'l1':[s/1e4 for s in range(0, 100, 10)],
                    'l2':[s/1e5 for s in range(0, 1000, 10)],
                    'input_dropout_ratio':[s/1e2 for s in range(0, 20, 2)]}

# define search strategy
search_criteria = {'strategy':'RandomDiscrete',
                   'max_models':20,
                   'max_runtime_secs':10000}

# initialize grid search
gsearch = H2OGridSearch(H2ODeepLearningEstimator,
                        hyper_params=hyper_parameters,
                        search_criteria=search_criteria)

# execute training w/ grid search
gsearch.train(x=X,
              y=y,
              training_frame=training,
              validation_frame=validation,
              train_samples_per_iteration = -1,
              score_training_samples = 0,
              score_validation_samples = 0)

gsearch.show()
gsearch.get_grid()[0]

#h2o.cluster().shutdown()