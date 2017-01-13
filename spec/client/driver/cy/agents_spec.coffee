describe "$Cypress.Cy Agents Commands", ->
  enterCommandTestingMode()

  context "#stub", ->
    beforeEach ->
      @stub = @cy.stub()

    it "synchronously returns stub", ->
      expect(@stub).to.exist
      expect(@stub.returns).to.be.a("function")

  context "#stub()", ->
    beforeEach ->
      @stub = @cy.stub()

    it "proxies sinon stub", ->
      @stub()
      expect(@stub.callCount).to.equal(1)

    it "has sinon stub API", ->
      @stub.returns(true)
      result = @stub()
      expect(result).to.be.true

  context "#stub(obj, 'method')", ->
    beforeEach ->
      @originalCalled = false
      @obj = {
        foo: => @originalCalled = true
      }
      @stub = @cy.stub(@obj, "foo")

    it "proxies sinon stub", ->
      @obj.foo()
      expect(@stub.callCount).to.equal(1)

    it "replaces method", ->
      @obj.foo()
      expect(@originalCalled).to.be.false

  context "#stub(obj, 'method', replacerFn)", ->
    beforeEach ->
      @originalCalled = false
      @obj = {
        foo: => @originalCalled = true
      }
      @replacementCalled = false
      @stub = @cy.stub @obj, "foo", =>
        @replacementCalled = true

    it "proxies sinon stub", ->
      @obj.foo()
      expect(@stub.callCount).to.equal(1)

    it "replaces method with replacement", ->
      @obj.foo()
      expect(@originalCalled).to.be.false
      expect(@replacementCalled).to.be.true

  context "#agents", ->
    beforeEach ->
      @agents = @cy.agents()

    it "is synchronous", ->
      expect(@agents).to.have.property("spy")
      expect(@agents).to.have.property("stub")
      expect(@agents).to.have.property("mock")

    it "uses existing sandbox"

    describe "#spy", ->
      it "proxies to sinon spy", ->
        spy = @agents.spy()
        spy()
        expect(spy.callCount).to.eq(1)

      describe ".log", ->
        beforeEach ->
          @Cypress.on "log", (attrs, @log) =>

          @cy.noop({})

        it "logs obj", ->
          spy = @agents.spy()
          spy("foo", "bar")

          expect(@log.get("name")).to.eq("spy-1")
          expect(@log.get("message")).to.eq("function(arg1, arg2)")
          expect(@log.get("type")).to.eq("parent")
          expect(@log.get("state")).to.eq("passed")
          expect(@log.get("snapshots").length).to.eq(1)
          expect(@log.get("snapshots")[0]).to.be.an("object")

        it "increments callCount", ->
          spy = @agents.spy()

          @agent = @log

          expect(@agent.get("callCount")).to.eq 0
          spy("foo", "bar")
          expect(@agent.get("callCount")).to.eq 1
          spy("foo", "baz")
          expect(@agent.get("callCount")).to.eq 2

        context "#consoleProps", ->

    describe ".log", ->
      it "logs even without cy current", ->
        spy = @agents.spy()

        logs = []

        @Cypress.on "log", (attrs, log) ->
          logs.push log

        spy("foo")

        commands = _(logs).filter (log) ->
          log.get("instrument") is "command"

        expect(commands.length).to.eq(1)
