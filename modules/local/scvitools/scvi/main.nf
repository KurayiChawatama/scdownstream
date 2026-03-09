process SCVITOOLS_SCVI {
    tag "${meta.id}"
    label 'process_medium'
    label 'process_gpu'

    conda "${moduleDir}/environment.yml"
    container "${task.ext.use_gpu
        ? 'ghcr.io/scverse/scvi-tools:py3.13-cu12-1.4.1-runtime'
        : workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container
            ? 'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/b2/b2de35dc0ce0c80a161c7baab1fbbe64b7c1991e901face1a9dc366d8c1046a5/data'
            : 'community.wave.seqera.io/library/scvi-tools:1.4.1--47f5b0e6b70fd131'}"

    input:
    tuple val(meta), path(h5ad, arity: 1)
    tuple val(meta2), path(reference_model, stageAs: 'reference_model/model.pt')
    val batch_col
    val categorical_covariates
    val continuous_covariates

    output:
    tuple val(meta), path("${prefix}.h5ad"), emit: h5ad
    tuple val(meta), path("${prefix}_model/model.pt"), emit: model
    path "X_${prefix}.pkl", emit: obsm
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    prefix = task.ext.prefix ?: "${meta.id}"
    n_hidden = task.ext.n_hidden ?: 128
    n_layers = task.ext.n_layers ?: 2
    n_latent = task.ext.n_latent ?: 30
    dispersion = task.ext.dispersion ?: 'gene'
    gene_likelihood = task.ext.gene_likelihood ?: 'zinb'
    max_epochs = task.ext.max_epochs ?: null

    if ("${h5ad}" == "${prefix}.h5ad") {
        error("Input and output names are the same, set prefix in module configuration to disambiguate!")
    }
    template('scvi.py')

    stub:
    prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.h5ad
    mkdir -p ${prefix}_model
    touch ${prefix}_model/model.pt
    touch X_${prefix}.pkl
    touch versions.yml
    """
}
