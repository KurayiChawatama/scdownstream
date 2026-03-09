process SCANPY_RANKGENESGROUPS {
    tag "${meta.id}"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container
        ? 'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/fd/fd27aeaf160eaba9a58c029e08f1da74051aa292c2fb043a5dd68fddcde3af93/data'
        : 'community.wave.seqera.io/library/pyyaml_scanpy:3c9e9f631f45553d'}"

    input:
    tuple val(meta), path(h5ad)
    val(obs_key)
    tuple val(filter_col), val(filter_val)
    val(method)

    output:
    tuple val(meta), path("*.h5ad"), emit: h5ad, optional: true
    path "*.pkl", emit: uns, optional: true
    path "*.png", emit: plots, optional: true
    path "*_mqc.json", emit: multiqc_files, optional: true
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    prefix = task.ext.prefix ?: "${meta.id}"
    template('rank_genes_groups.py')

    stub:
    prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch "${prefix}.h5ad"
    touch "${prefix}.pkl"
    touch "${prefix}.png"
    touch "${prefix}_mqc.json"
    touch "versions.yml"
    """
}
