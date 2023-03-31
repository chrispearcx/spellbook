{{ config(
        alias ='trades',
        post_hook='{{ expose_spells(\'["ethereum","arbitrum", "bnb"]\',
                                "project",
                                "uniswap",
                                \'["jeff-dude","chrispearcx"]\') }}'
        )
}}

{% set uniswap_models = [
ref('uniswap_ethereum_liquidity')
,ref('uniswap_bnb_liquidity')
] %}


SELECT *
FROM (
    {% for dex_model in uniswap_models %}
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
    UNION ALL
    {% endif %}
    {% endfor %}
)
;