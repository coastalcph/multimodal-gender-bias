#!/bin/bash
#SBATCH --job-name=vqa_lxmert180k_neutral-eval
#SBATCH --ntasks=1 --cpus-per-task=1
#SBATCH --mem=60G
#SBATCH -p gpu --gres=gpu:1
#SBATCH --time=1-00:00:00
#SBATCH --output=eval.out
#SBATCH --error=eval.err

export PYTHONPATH=$(builtin cd ..; pwd)

. ../../main.config

name=lxmert_180k_neutral
task=1
task_name=VQA
configs=volta/config/original_lxmert.json
ckpt=${OUTS_DIR}/${task_name}/${name}/pytorch_model_best.bin
output=${OUTS_DIR}/${task_name}/${name}
logs=logs/${task_name}/${name}

echo "Task ${task}: ${task_name}"

# VALIDATION
task_config_file=volta/config_tasks/all_trainval_tasks.yml

python LXMERT/eval_task.py \
	--config_file ${configs} \
	--from_pretrained ${ckpt} \
	--tasks_config_file ${task_config_file} \
	--task $task \
	--output_dir ${output} \
	--logdir ${logs} \
	--save_name "val"

# TEST
# https://visualqa.org/challenge.html
task_config_file=volta/config_tasks/all_test_tasks.yml

python LXMERT/eval_task.py \
	--config_file ${configs} \
	--from_pretrained ${ckpt} \
	--tasks_config_file ${task_config_file} \
	--task $task \
	--output_dir ${output} \
	--logdir ${logs} \
	--save_name "test"

conda deactivate
