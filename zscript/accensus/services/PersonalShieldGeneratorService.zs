Class HDPersonalShieldGeneratorService : Service {

    override int GetInt(String request, string stringArg, int intArg, double doubleArg, Object objectArg) {

        let p = HDPlayerPawn(objectArg); if (!p) return -1;
        let g = HDPersonalShieldGenerator(p.FindInventory("HDPersonalShieldGenerator")); if (!g) return -1;

        // Process the request
        if (request ~== "GeneratorEnabled") { return HandleGeneratorEnabled(g); }
        if (request ~== "GeneratorFluxCap") { return HandleGeneratorFluxCap(g); }
        return -1;
    }
    
    override int GetIntUI(String request, string stringArg, int intArg, double doubleArg, Object objectArg) {

        let p = HDPlayerPawn(objectArg); if (!p) return -1;
        let g = HDPersonalShieldGenerator(p.FindInventory("HDPersonalShieldGenerator")); if (!g) return -1;

        // Process the request
        if (request ~== "GeneratorEnabled") { return HandleGeneratorEnabled(g); }
        if (request ~== "GeneratorFluxCap") { return HandleGeneratorFluxCap(g); }
        return -1;
    }

    private clearscope int HandleGeneratorEnabled(HDPersonalShieldGenerator g) {
        return g.enabled;
    }

    private clearscope int HandleGeneratorFluxCap(HDPersonalShieldGenerator g) {
        return g.GetFluxCapacity();
    }
}