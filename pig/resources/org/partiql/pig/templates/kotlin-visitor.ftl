[#ftl output_format="plainText"]
[#-- @ftlvariable name="universe" type="org.partiql.pig.generator.kotlin.KTypeUniverse" --]

[#macro tuple_walker_body t visitSuffix]
    [@indent count=4]
    visit${visitSuffix}(node)
        [#list t.properties as p]
            [#if p.variadic]
    node.${p.kotlinName}.map { walk${p.rawTypeName}(it) }
            [#elseif p.nullable]
    node.${p.kotlinName}?.let { walk${p.rawTypeName}(it) }
            [#else]
    walk${p.rawTypeName}(node.${p.kotlinName})
            [/#if]
        [/#list]
    walkMetas(node.metas)
    [/@indent]
[/#macro]

open class Visitor : DomainVisitorBase() {
    ////////////////////////////////////////////////////////////////////////////
    // Visit Functions
    ////////////////////////////////////////////////////////////////////////////

    [#list domain.tuples]
    //////////////////////////////////////
    // Tuple Types
    //////////////////////////////////////
    [#items as t]
    open fun visit${t.kotlinName}(node: ${domain.kotlinName}.${t.kotlinName}) { }
    [/#items]
    [/#list]
    [#list domain.sums as s]
    //////////////////////////////////////
    // Sum Type: ${s.kotlinName}
    //////////////////////////////////////
    protected open fun visit${s.kotlinName}(node: ${domain.kotlinName}.${s.kotlinName}) { }
[#list s.variants as t]
    protected open fun visit${s.kotlinName}${t.kotlinName}(node: ${domain.kotlinName}.${s.kotlinName}.${t.kotlinName}) { }
[/#list]
    [/#list]

    ////////////////////////////////////////////////////////////////////////////
    // Walk Functions
    ////////////////////////////////////////////////////////////////////////////

    [#list domain.tuples]
    //////////////////////////////////////
    // Tuple Types
    //////////////////////////////////////
    [#items as t]
    open fun walk${t.kotlinName}(node: ${domain.kotlinName}.${t.kotlinName}) {
        [@tuple_walker_body t t.kotlinName/][#t]
    }

    [/#items]
    [/#list]
    [#list domain.sums as s]
    //////////////////////////////////////
    // Sum Type: ${s.kotlinName}
    //////////////////////////////////////
    open fun walk${s.kotlinName}(node: ${domain.kotlinName}.${s.kotlinName}) {
        visit${s.kotlinName}(node)
        when(node) {
        [#list s.variants as v]
            is ${domain.kotlinName}.${s.kotlinName}.${v.kotlinName} -> walk${s.kotlinName}${v.kotlinName}(node)
        [/#list]
        }
    }

[#list s.variants as t]
    open fun walk${s.kotlinName}${t.kotlinName}(node: ${domain.kotlinName}.${s.kotlinName}.${t.kotlinName}) {
        [@tuple_walker_body t "${s.kotlinName}${t.kotlinName}"/]
    }

[/#list]
[/#list]
}
