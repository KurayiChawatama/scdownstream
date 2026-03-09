process ADATA_SETINDEX {
    tag "${meta.id}"
    label 'process_single'

    conda "${moduleDir}/environment.yml"
    container "${workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container
        ? 'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/76/7612a78c6f49cfbeebf84c444ad314bf86da041588f3b0f14951e462e18a9228/data'
        : 'community.wave.seqera.io/library/anndata_pyyaml:82c6914e861435f7'}"

    input:
    tuple val(meta), path(h5ad)
    val axis
    val column

    output:
    tuple val(meta), path("${prefix}.h5ad"), emit: h5ad
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    prefix = task.ext.prefix ?: "${meta.id}"

    if (!(axis in ["obs", "var"])) {
        error("Axis must be either 'obs' or 'var', but got '${axis}'! Use \"task.ext.axis\" to set it!")
    }
    if ("${prefix}.h5ad" == "${h5ad}") {
        error("Input and output names are the same, use \"task.ext.prefix\" to disambiguate!")
    }
    template('setindex.py')

    stub:
    prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.h5ad
    touch versions.yml
    """
}
