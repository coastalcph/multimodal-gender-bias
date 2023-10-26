#!/bin/bash
#SBATCH --job-name=albef14m_cc3m_neutral
#SBATCH --ntasks=1 --cpus-per-task=16
#SBATCH --mem=96G
#SBATCH -p gpu --gres=gpu:a100:4
#SBATCH --time=02:00:00
#SBATCH --output=train.out
#SBATCH --error=train.err

CODE_DIR=${CODE_DIR}/ALBEF


name=albef_14m_cc3m_neutral
task=VQA
configs=configs/${task}.yaml
ckpt=${OUTS_DIR}/Pretrain_CC3M_neutral/albef_14m/checkpoint_00.pth 
output=${OUTS_DIR}/${task}/${name}

mkdir -p $output

. /etc/profile.d/modules.sh
module load anaconda3/5.3.1
module load cuda/11.3
eval "$(conda shell.bash hook)"
source ${ENVS_DIR}/albef/bin/activate

cd $CODE_DIR
CUDA_VISIBLE_DEVICES="0,2,3,4" python -m torch.distributed.run --nproc_per_node=4 --master_port $(($RANDOM + $RANDOM)) VQA.py \
    --distributed \
    --config $configs \
    --checkpoint $ckpt \
    --output_dir $output \
    --wandb_project ${WANDB_PROJ} \
    --wandb_entity ${WANDB_ENT} \
    --wandb_run ${name}-${task} \
    # --resume \
    # --device cpu

deactivate
