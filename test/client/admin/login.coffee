should = require 'should'
phantom = require 'phantom'

describe 'Server', () ->
    it "should load login page", (done) ->
        phantom.create (ph) ->
            ph.createPage (page) ->
                page.open 'http://localhost:8080/admin/login', (s) ->
                    s.should.be.eql 'success'

                    fn = ->
                        user = $('input[name="username"]').size()
                        pass = $('input[name="password"]').size()
                        return {user, pass}

                    page.evaluate fn, (result) ->
                        result.user.should.be.exactly 1
                        result.pass.should.be.exactly 1

                        ph.exit()
                        done()
    it "should do login", (done) ->
        phantom.create (ph) ->
            ph.createPage (page) ->
                page.open 'http://localhost:8080/admin/login', (s) ->
                    s.should.be.eql 'success'

                    submitForm = ->
                        $('input[name="username"]').val 'admin'
                        $('input[name="password"]').val 'passwd1'
                        $('button[type="submit"]').trigger 'click'

                    checkResult = ->
                        document.URL
                    
                    page.evaluate submitForm, (result) ->
                        page.evaluate checkResult, (result) ->
                            result.should.be.eql 'http://localhost:8080/admin/dashboard'

                            done()