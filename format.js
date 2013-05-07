var data = {
    /* Two basic sections. */
    "Nodes": {
        /* Nodes is a int->node map.
         * nodes that already exist are updaasdted
         * by the fields supplied in the Nodes section
         * delete a node by passing `null` or a string as the value 
         *
         * id, name, class fields required for new node creationjsdfA
         * */
        // create node 1
        1: {id:1, name:"Router", classes:["server", "blue-team"], data:{ /* misc properties */ } },
        // update node 5
        5: {classes:["down", "compromised"], data:{ "last-pwned-at": /*Native DATE here*/ Date.now()} },
        // fast delete 24445
        24445: null,
        // delete with reason 512
        512: "hit with hammer"
    },

    "Edges": {
        /* same deal as before, except with different required fields
         * from: and to: are both Node IDs.
         * classes is the same
         */
        // create
        5334: {from: 1, to: 5, classes: ["http", "suspicious"]},
        // update
        12223: {classes: ["port-scan"]},
        // delete - string with termination reason, or null to prune quickly
        121: "client-terminated",
        3233: null
    }
}

// output object as valid JSON
var str = JSON.stringify(data, null, 2)
console.log(str)

