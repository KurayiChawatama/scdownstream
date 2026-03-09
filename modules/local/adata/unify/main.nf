process ADATA_UNIFY {
    tag "${meta.id}"
    label 'process_single'

    conda "${moduleDir}/environment.yml"
    container "${workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container
        ? 'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/76/7612a78c6f49cfbeebf84c444ad314bf86da041588f3b0f14951e462e18a9228/data'
        : 'community.wave.seqera.io/library/anndata_pyyaml:82c6914e861435f7'}"

    input:
    tuple val(meta), path(h5ad)
    val batch_col
    val label_col
    val condition_col
    val unknown_label
    val symbol_col
    val counts_layer
    val duplicate_var_resolution
    val aggregate_isoforms

    output:
    tuple val(meta), path("*.h5ad"), emit: h5ad
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    prefix = task.ext.prefix ?: "${meta.id}"
    template('unify.py')

    stub:
    prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.h5ad
    touch versions.yml
    """
}
