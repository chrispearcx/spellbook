{{ config(
        alias ='liquidity',
        partition_by = ['block_date'],
        materialized = 'incremental',
        file_format = 'delta',
        incremental_strategy = 'merge',
        unique_key = ['block_date', 'blockchain', 'project', 'version', 'tx_hash', 'evt_index', 'trace_address'],
        post_hook='{{ expose_spells(\'["ethereum", "bnb"]\',
                                "sector",
                                "dex",
                                \'["jeff-dude", "hosuke", "chriespearcx"]\') }}'
        )
}}


{% set dex_liquidity_models = [
 ref('uniswap_liquidity')
,ref('sushiswap_liquidity')
,ref('pancakeswap_liquidity')
] %}


SELECT *
FROM (
    {% for dex_model in dex_liquidity_models %}
    SELECT
        blockchain,
        project,
        version,
        block_date,
        block_time,
        token_a_symbol,
        token_b_symbol,
        token_pair,
        token_a_amount,
        token_b_amount,
        token_a_amount_raw,
        token_b_amount_raw,
        amount_usd,
        token_a_address,
        token_b_address,
        -- taker,
        -- maker,
        project_contract_address,
        tx_hash,
        tx_from,
        tx_to,
        trace_address,
        evt_index
    FROM {{ dex_model }}
    {% if not loop.last %}
    {% if is_incremental() %}
    WHERE block_date >= date_trunc("day", now() - interval '1 week')
    {% endif %}
    UNION ALL
    {% endif %}
    {% endfor %}
)