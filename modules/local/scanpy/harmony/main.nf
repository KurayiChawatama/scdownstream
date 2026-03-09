process SCANPY_HARMONY {
    tag "${meta.id}"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container
            ? 'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/6f/6fc2d5f7918879823dcda31eb6e0d22131262c4e00bd36ca8b687150a661d5ba/data'
            : 'community.wave.seqera.io/library/harmonypy_pyyaml_scanpy:f6cc57196369fb1e'}"

    input:
    tuple val(meta), path(h5ad)
    val(batch_col)
    val(counts_layer)

    output:
    tuple val(meta), path("${prefix}.h5ad"), emit: h5ad
    path "X_${prefix}.pkl", emit: obsm
    path "versions.yml", emit: versions

    script:
    prefix = task.ext.prefix ?: "${meta.id}"
    if ("${prefix}.h5ad" == "${h5ad}") {
        error "Input and output names are the same, use \"task.ext.prefix\" to disambiguate!"
    }
    template('harmony.py')

    stub:
    prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.h5ad
    touch X_${prefix}.pkl
    touch versions.yml
    """
}
